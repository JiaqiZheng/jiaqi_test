% -----------------------------------------------------------------------------
%
% CSF-Bnr Demo : non-rigid SFM with simulated occlusion
%
% -----------------------------------------------------------------------------
clear all

NUM_DATASET = 3;             % selects a dataset ({1,2,3}, see strings below)
PERC_OCCLUSION = 50;         % percentage of simulated missing data

% Available datasets (used by Torresani, Hertzmann, and Bregler, PAMI 2008)
strings = { 'jaws', 'walking', 'face2' };

% parameters for each dataset:
r0 = { 7, 7, 5 };            % matrix rank parameter of initial CSF-Baf step
d0 = { 0.25, 0.25, 0.5 };    % number (%) of DCT vectors in initial CSF-Baf step

Ks = { 3, 2, 3 };            % number of basis shapes (rank) for CSF-Bnr
ds = { 0.1, 0.1, 0.3333 };   % number (%) of DCT vectors in CSF-Bnr

% Load data (original 3D shapes and observation matrix with 2D points)
[S0,W] = pgLoadDataNRSFM( strings{NUM_DATASET} );
[T,n] = size(W); T = T / 2;          % number of frames and points

% -----------------------------------------------------------------------------
% Simulate occlusion and then reconstruct the 2D point trajectories in W
% using CSF-Baf

PERC_OCCLUSION = PERC_OCCLUSION / 100;
VALID = pgRandomOcclusion( W, 3*Ks{NUM_DATASET}, PERC_OCCLUSION );
W0 = W;
W(~VALID(:)) = NaN;
perc = 100 * sum(isnan(W(:))) / numel(W);
fprintf('Missing data: %3.1f %% \n', perc)
figure, imagesc(VALID),
title(sprintf('Missing data in W (blue pixels, %3.1f %%)', perc)), drawnow()

raf = r0{NUM_DATASET};                      % rank of initial factorization
daf = fix( d0{NUM_DATASET} * T );           % number of DCT frequency components
Baf = kron( idct( eye(T,daf) ), eye(2) );   % basis for M

disp('Reconstructing W using CSF-Baf...')
[Maf,Saf] = pgCSFmean( W, raf, [], 200, 1e-6, false, Baf );
Waf = Maf * Saf;

% Compute normalized 2D error of CSF-Baf
E = W0 - Waf;
E2 = sqrt( E(1:2:end,:).^2 + E(2:2:end,:).^2 );
err2D = mean( E2(:) ) / mean( std( W0,1,2 ) );

fprintf('Normalized 2D reprojection error: %5.4f \n', err2D)

% -----------------------------------------------------------------------------
% Estimate camera matrices using PTA's Euclidean upgrade method:
[D,Rs] = pgComputeD( Waf );          % Rs has the rotations in the diagonal of D

t = Maf(:,end);                      % reconstructed mean column of W from above
Wc = W - repmat(t,1,n);              % centered, incomplete W

% Run CSF-Bnr to compute the shape trajectory and associated basis shapes
K = Ks{NUM_DATASET};                 % number of basis shapes (rank-3K)
d = ceil( ds{NUM_DATASET} * T );     % number of DCT frequency components

disp('Recoverying 3D shapes using CSF-Bnr...')
[X,M,S,S3] = pgCSF_Bnr_occlusion( Wc, D, K, d, 100, 1e-6 );

% -----------------------------------------------------------------------------
% Align original and recovered 3D shapes
[S0R,S3R] = alignStruct( S0, S3, Rs ); 
       
% Compute normalized, average 3D error
errS = zeros(T,n);                                  % 3D reconstruction errors
for t = 1:T, t3 = 3*t-[2 1 0];
    errS(t,:) = sqrt(sum( (S0R(t3,:)-S3R(t3,:)).^2 )); % 3D Euclidean distance
end
s = mean( std(S0R,1,2) );                           % "scale" (avg row std.dev.)
err3D = mean(errS(:)) / s;

fprintf('err3D = %5.4f (K = %d, d = %d)\n', err3D, K, d)

% -----------------------------------------------------------------------------
% visualize reconstructed shapes

figure, pgShowShapes3D(S0R, S3R);
