function [ M,S ] = getM( W, show )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

T = size(W,1) / 2;
% fprintf('\nMissing data: %3.1f %% \n', 100*sum(isnan(W(:)))/numel(W))

% Parameters of CSF-Bwp
x0 = [];                      % start with deterministic initialization
d  = (0.2:0.2:1.0) * T;       % repeatedly run CSF-Bwp with increasing d

% Coarse-to-fine optimization strategy for CSF-Bwp
x = x0;
d = fix(d);
d((d <= 1)) = 2; % if the sequence is too short, the number of basis may be deficient.
                 % I change the d(d == 1) to d(d <= 1), for the squece that
                 % is less than 4.
n = numel(d);
% fprintf('Running coarse-to-fine optimization strategy:\n')
for k = 1:n
%     fprintf('\n Starting CSF-Bwp (d = %3.2fT = %d):  ', d(k)/T, d(k))
    
    % speed up: use a smaller TOL if this is not the last run of CSF-Bwp
    if (k < n), TOL = 1e-4; else TOL = 1e-6; end
    
    [M,S,x,rmse,iter] = pgCSF_Bwp( W, x, d(k), 100, TOL, false );
    
%     fprintf('iter = %-4d  RMSE = %-8.6f\n', iter, rmse)
end

% Reconstructed (complete) W:
Wr = M * S;
% RMSE = sqrt(nanmean( (W(:)-Wr(:)).^2 )) 

% Display complete 2D point trajectories and the recovered Euclidean shape
if show
    figure, subplot(1,2,1), plot( Wr(1:2:end,:), Wr(2:2:end,:) ), axis equal ij
    title('Reconstructed 2D point trajectories of W')
    subplot(1,2,2), plot3( S(1,:), S(2,:), S(3,:), '.k', 'MarkerSize', 12 )
    xlabel('x'), ylabel('y'), zlabel('z'), axis equal, grid on
    title('Reconstructed Euclidean 3D shape')
end

end

