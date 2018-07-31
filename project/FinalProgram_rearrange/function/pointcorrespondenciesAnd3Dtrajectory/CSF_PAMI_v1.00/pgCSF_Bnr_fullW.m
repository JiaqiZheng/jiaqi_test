
function [X,M,S,t,S3] = pgCSF_Bnr_fullW( W, D, K, d, maxIter, RMSE_TOL )
% function [X,M,S,t,S3] = pgCSF_Bnr_fullW( W, D, K, d, maxIter, RMSE_TOL )
%
% Matrix factorization for non-rigid structure from motion (no occlusion)
%
% By Paulo Gotardo
%
% Inputs:
%
% W is the observation matrix (here it is assumed complete; no missing data)
% D is the block diagonal matrix of camera projections (orthographic model)
% K is the factorization rank parameter (number of basis shapes)
% d is the number of DCT components in the shape trajectory X (a d-by-K matrix)
% maxIter is the maximum number of iterations
% RMSE_TOL is the parameter of the stopping (convergence) rule
%
% Outputs:
%
% X is a compact representation of shape trajectory (coefficients) in DCT domain
% M is the 2T-by-3K motion factor
% S is the 3K-by-n  factor with K basis shapes (each one is 3-by-n)
% t is the mean column vector of W (2D translations due to camera motion)
% S3 is 3T-by-n, the t^th triplet or rows has the recovered 3D shape for image t
%
pgCheckBuildKronmex()

if (nargin < 6), RMSE_TOL = 1e-7; end
if (nargin < 5), maxIter  = 100; end

T = size(W,1) / 2;
n = size(W,2);

% estimate translation vector t and make W zero mean
t = mean(W,2);
Wc = W - repmat(t, 1, n);

X = pgGaussNewton( Wc, D, K, d, maxIter, RMSE_TOL );

% ----------------------------------------------------------------------------
% Compute final M,S, and the recovered 3D shapes

O = idct( eye(T,d) );
C = O*X;
M = D * kronmex( C, eye(3));
S = pinv(M) * Wc;
S3 = kronmex( C, eye(3) ) * S;

% -----------------------------------------------------------------------------
% Damped-Newton (i.e. Levenberg-like) non-linear optimization method

function X = pgGaussNewton (W, D, K, d, numIter, RMSE_TOL )

% Generate DCT basis and initial 3D shape trajectory in DCT domain
T  = size(W,1) / 2;                  % number of images (frames)
Od = idct( eye(T,d) );               % truncated DCT basis with d vectors
X  = eye(d,K);                       % deterministic initialization of X

% Constants
nx = numel(X);
Id = eye(nx);                        % used for damping Hessian matrix
delta = 1e-4;                        % initial damping parameter for Hessian
I3 = eye(3);
V  = sparse( pgVecAxI (d, K, 3) );    % mapping matrix: vec(kron(X,I3)) = V vec(X)
Vt = V';
%g  = zeros(nx,1);                   % gradient vector
%H  = zeros(nx);                     % Hessian matrix
Bnr  = D * kronmex( Od, I3 );
Bnrt = Bnr';
BnrtBnr = Bnrt*Bnr;

% Compute initial factors M, M+, S, R, and RMSE
M = D * kronmex( Od*X, I3 );
piM = pinv(M);                       % pseudo inverse of M
S = piM * W;                         % structure factor (basis shapes)
R = W - M*S;                         % error matrix     (residues)

% Initial 2D fit error (initial cost of f(M))
RMSE = zeros(numIter+1,1);
RMSE(1) = sqrt(mean(R(:).^2));
fprintf('\ni = 0 \t RMSE = %-15.10g\n', RMSE(1) )

% Main loop
warning('off', 'MATLAB:nearlySingularMatrix');     % OK! Damping fixes Hessian
for iter = 1:numIter
        
    % (1a) Calculate gradient (g) from df = tr(R'dR) = vec(kron(X,I3))'vec(ZZ)
    ZZ = (Bnrt * R) * S';
    g  = -(Vt * ZZ(:));

    % (1b) Compute the Hessian (H) from the Jacobian matrix product J'J
    YY = BnrtBnr - (Bnrt*M) * (piM*Bnr);           % Bnr'*(I-MM+)*Bnr
    H  = Vt * kronmex(S*S', YY) * V;               % H = J'*J;
             
    % (2) Repeat solving for vec_dX until f(X-dX) < f(X) or converged
    while true
        vec_dX = pinv(H + delta*Id) * g;
        %vec_dX = (H + delta*Id) \ g;
        newX = X - reshape( vec_dX, [], K );

        % Orthonormalize newX for numerical stability (newX is non-unique)
        [newX,foo] = qr(newX,0);
                
        % Recompute factors
        M = D * kronmex( Od*newX, I3 );
        piM = pinv(M);                 % pseudo inverse
        S = piM * W;                   % structure factor (basis shapes)
        R = W - M*S;                   % error matrix     (residues)

        % Evaluate cost f(newX)
        R2 = R.^2;
        new_rmse = sqrt(mean(R2(:)) );
        max_err  = sqrt( max(R2(:)) );
                    
        % damping termination tests
        if (new_rmse < RMSE(iter)), OK = true; break, end 
        
        % line search book-keeping...
        delta = delta * 10;
        if (delta > 1.0e30), OK = false; break, end
    end                                                            % end while
    % Error test (bailed out with no descent)
    if (~OK), disp('Error: cannot find descent direction!'), break, end

    % (3) Book-keeping: update parameters
    X = newX;
    delta = max( delta / 100, 1.0e-20 );
    RMSE(iter+1) = new_rmse;
    
    % (4) Display new error and test convergence
    fprintf('i = %-4d \t l = 1e%03d \t RMSE = %-15.10g (max %g)\n', ...
            iter, fix(log10(delta)), new_rmse, max_err )
    
    if (iter > 1 && RMSE(iter-1) - RMSE(iter+1) < RMSE_TOL)
        disp('Converged!'), break
    end
end

% Truncate vector of RMSE values
RMSE = RMSE(1:iter);
if (iter == numIter), disp('Stopped: max # iterations.'), end

warning('on', 'MATLAB:nearlySingularMatrix');

% ----------------------------------------------------------------------------
% Magnus&Neudecker (execise pg48):
% vec(kron(Ih,A)) = kron(H,Im) vec(A) = Ch vec(A), where A is m-by-n

function K = pgVecAxI (m,n, i)

I = eye(i);
G = kronmex(pgKmn(i,m), I) * kronmex(eye(m), I(:));
K = kronmex(eye(n), G);

% ----------------------------------------------------------------------------
% Commutation matrix for m-by-n A: vec(A') = K * vec(A);

function Kmn = pgKmn (m, n)

na = m*n;
Pos = reshape(1:na, [ m n ])';

Kmn = zeros(na,na);
for row = 1:na
    Kmn(row, Pos(row)) = 1;
end
% ----------------------------------------------------------------------------
