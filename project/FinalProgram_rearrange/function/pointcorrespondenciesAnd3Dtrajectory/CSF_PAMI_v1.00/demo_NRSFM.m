%
%
% CSF-Bnr Demo : non-rigid SFM with a shape trajectory approach (STA model)
%
%
% -----------------------------------------------------------------------------
clear all

NUM_DATASET = 1;             % selects a dataset ({1,2,3}, see strings below)

% Available datasets (used by Torresani, Hertzmann, and Bregler, PAMI 2008)
strings = { 'jaws', 'walking', 'face2' };

% parameters for each dataset:
Ks = { 3, 2, 3 };            % number of basis shapes (rank parameter)
ds = { 0.1, 0.1, 0.3333 };   % number (%) of vectors in the truncated DCT basis

% Load data (original 3D shapes and observation matrix with 2D points)
[S0,W] = pgLoadDataNRSFM( strings{NUM_DATASET} );
[T,n] = size(W); T = T / 2;          % number of frames and points

% -----------------------------------------------------------------------------
% Estimate camera matrices using PTA's Euclidean upgrade method:
[D,Rs] = pgComputeD( W );            % Rs has the rotations in the diagonal of D

% Run CSF-Bnr to compute the shape trajectory and associated basis shapes
K = Ks{NUM_DATASET};                 % number of basis shapes (rank-3K)
d = ceil( ds{NUM_DATASET} * T );     % number of DCT frequency components

[X,M,S,t,S3] = pgCSF_Bnr_fullW( W, D, K, d, 100, 1e-6 );

% NOTE: considering the same cameras in D, and the same rank parameter K,
% the final result of the PTA algorithm is the initial solution of CSF-Bnr:
% [X,M,S,t,S3] = pgCSF_Bnr_fullW( W, D, K, d, 0,0);  % performs 0 iterations

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
