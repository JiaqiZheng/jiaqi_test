
function [ P3_gt, W ] = pgLoadDataNRSFM( string )
%function [ P3_gt, W ] = pgLoadDataNRSFM( string )
%
% where string = {'jaws','face2,'walking'}
%
% Shark data has 240 frames, 91 points (P3_gt is 720x91)
% Face mocap has 316 frames, 40 points (P3_gt is 948x40)
% Walking mocap: 260 frames, 55 points (P3_gt is 780x55)
%
% loads the matrix P3_gt containing the ground thruth 3D shapes:
% P3_gt([t t+T t+2*T],:) contains the 3D coordinates of the J points at time t
% (T is the number of frames, J is the number of points)
% 
% [T, J] = size(P3_gt); T = T/3;
%
% 2D motion from orthographic projection (input to the non-rigid SFM algorithm)
%
% p2_obs = P3_gt([ 1 T+1 2 T+2 3 T+3 ... ], :);

load([ './data/' string '.mat' ]);
T = size(P3_gt,1) / 3;
vect = 1:T;

% Adjusts matrix with 2D observations
rows = reshape([ vect ; vect+T ], [], 1); 
W = P3_gt(rows,:);
% W(2*t -[1 0], :) contains the 2D projection of the J points at time t

% Adjust matrix with 3D shapes [ 1 T+1 2 T+2 3 T+3 ... ]'
rows = reshape([ vect ; vect+T ; vect+T+T ], [], 1);  
P3_gt = P3_gt(rows,:);
