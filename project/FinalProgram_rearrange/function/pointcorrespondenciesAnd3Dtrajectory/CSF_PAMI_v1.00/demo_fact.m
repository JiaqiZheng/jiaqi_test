%
%
% CSF Demo : general matrix factorization with missing data
%
%
clear all

% Loads 2D point tracks of the dinosaur on a turn table
% (clean subset of 319 point tracks, after outlier removal)
% obtained from: http://www.robots.ox.ac.uk/~amb/

load('./data/dino319.mat')   % loads W
fprintf('Missing data: %3.1f %% \n', 100*sum(isnan(W(:)))/numel(W))

T = size(W,1) / 2;            % maximum number of 2D points in each column

% Construct the DCT basis
d  = fix(1.0 * T);            % number (%) of DCT vectors used below                 
Od = idct( eye(T,d) );        % DCT basis with d frequency components

% Parameters of CSF
RANK_W = 4;                   % rank of W and M
B  = kron( Od, eye(2) );      % basis for M = BX
X0 = [];                      % use deterministic initialization with DCT basis

MAX_ITER = 100;               % maximum number of iterations
RMSE_TOL = 1e-7;              % stopping rule (min error improvement)
verbose  = true;              % display information after each iteration

% The two function calls below differ on whether or not 
% the last row of factor S is forced to be all 1s
% (with the last column of factor M giving a mean column vector t)

%[M,S,X,rmse,iter] = pgCSF    ( W, RANK_W, X0, MAX_ITER, RMSE_TOL, verbose, B);
[M,S,X,rmse,iter] = pgCSFmean( W, RANK_W, X0, MAX_ITER, RMSE_TOL, verbose, B);

% NOTE 1: you should try both versions and compare the resulting plots!
% Although pgCSF() provides the smallest known RMSE for this dataset,
% pgCSFmean() reconstructs trajectories in W that are visually more accurate.
% This is due to the different number of degrees of freedom of the two models.
% See discussion in the paper.

% NOTE 2: you should also experiment with the canonical basis (M=BX with B=I):
% B  = eye(size(W,1));
% X0 = orth( rand( size(W,1), RANK_W ));  % random init when not using DCT basis

% Reconstructed (complete) W:
Wr = M*S;

% Display complete 2D point trajectories
figure, plot( Wr(1:2:end,:), Wr(2:2:end,:) ), axis equal ij
title('Reconstructed 2D point trajectories of W')
