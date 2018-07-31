function [D,Rs] = pgComputeD ( Wcomp, ENERGY )
%function [D,Rs] = pgComputeD ( Wcomp, ENERGY )
%
% Wcomp is the observation matrix W (assumed complete)
%
% ENERGY is a threshold for truncating the SVD of M
% Default: 0.0001 (or 0.01%) of the total energy is discarded
%
% This mfile is based in part on the Euclidean upgrade code by
% Akhter, Sheikh, Khan, and Kanade:
% "Nonrigid Structure from Motion in Trajectory Domain", NIPS 2008.
% http://cvlab.lums.edu.pk/nrsfm/
%
% Modified by Paulo Gotardo
%
if (nargin < 2), ENERGY = 0.0001; end

[numF,numP] = size(Wcomp); numF = numF/2;

% Centered observation matrix
Wcomp = Wcomp - repmat( mean(Wcomp,2), 1, numP );

% Compute SVD of W and retrieve cameras
[U,Sigma,V] = svd(Wcomp,'econ');
ns = 3 * ceil( sum( diag(Sigma)/Sigma(1) > ENERGY ) / 3 );
if (ns > size(U,2)), ns = ns - 3; end

M = U(:,1:ns) * sqrt( Sigma(1:ns,1:ns) );

Rs = NRSFM_getCamerasFromM( M );

% Compute camera matrix D
D = sparse(2*numF, 3*numF);
for f = 1:numF
    f2 = 2*f-[1 0]; f3 = 3*f-[2 1 0];
    D(f2,f3) = Rs(f2,:);
end

%-----------------------------------------------------------------------------

function Rs = NRSFM_getCamerasFromM( M )
%
% Finds best Q such that:
%
% Rs = M * Q;  % returns 2Fx3 matrix of Euclidean cameras
%

fprintf('\nStarting recovery of Euclidean cameras...\n')
warning('off', 'optim:fminunc:SwitchingMethod')

[Q,fval] = pgGetCameras (M, eye(3), Inf);
Rs = M(:, 1:size(Q,1) ) * Q;

warning('on', 'optim:fminunc:SwitchingMethod')

fprintf(' Done!\n')

% -----------------------------------------------------------------------------

function [Q,fval] = pgGetCameras (M, Q0, fval0)
%
% Based on the Euclidean upgrade code by Akhter, Sheikh, Khan, and Kanade:
% "Nonrigid Structure from Motion in Trajectory Domain", NIPS 2008.
%
% Modified by Paulo Gotardo

% options = optimset('Diagnostics','off','Display','iter','MaxFunEval',100000,'MaxIter',2000,'TolFun',1e-10,'TolX',1e-10);
options = optimset('Display', 'off', 'Diagnostics','off', 'MaxFunEval', 100000,...
                   'MaxIter', 2000 , 'TolFun', 1e-10, 'TolX', 1e-10);

% (1) Perform optimization with enlarged Q0
ncols = size(Q0,1) + 3;
[Q,fval] = fminunc( @evalQ, [ Q0 ; zeros(3) ], options, M(:, 1:ncols) ); 

% (2) If no improvement, end recursive procedure (returns Rs in Q)!
if (fval >= fval0), fval = fval0; Q = Q0; return, end

% (3) display progress
fprintf('.')

% (4) Perform another recursive call
if ( size(M,2) >= ncols + 3 )
    [Q,fval] = pgGetCameras (M, Q, fval);
end

% -----------------------------------------------------------------------------

function f = evalQ ( q, M )
%
% Based on code by Akhter, Sheikh, Khan, and Kanade:
% "Nonrigid Structure from Motion in Trajectory Domain", NIPS 2008.
%
% Modified by Paulo Gotardo

Rbar = M * q;        % Rbar(2F,3), rotation matrices

Rbar1 = Rbar(1:2:end, :);
Rbar2 = Rbar(2:2:end, :);

onesArr = [ sum(Rbar1.^2, 2); sum(Rbar2.^2, 2)];
zerosArr = sum(Rbar1.*Rbar2, 2);

f = sum( (onesArr-1).^2 ) + sum(zerosArr.^2);
f = 2 * f / size(M,1);

% -----------------------------------------------------------------------------
