
function [X,M,S,S3] = pgCSF_Bnr_occlusion( W, D, K, d, maxIter, RMSE_TOL )
% function [X,M,S,S3] = pgCSF_Bnr_occlusion( W, D, K, d, maxIter, RMSE_TOL )
%
% Matrix factorization for non-rigid structure from motion with occlusion
%
% By Paulo Gotardo
%
% Inputs:
%
% W is the CENTERED observation matrix with missing data
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
% S3 is 3T-by-n, the t^th triplet or rows has the recovered 3D shape for image t
%
pgCheckBuildKronmex()

if (nargin < 6), RMSE_TOL = 1.0e-7; end
if (nargin < 5), maxIter  = 100; end

[X,M,S,C] = pgGaussNewton( W, D, K, d, maxIter, RMSE_TOL );

% Compute the recovered 3D shapes
S3 = kronmex( C, eye(3) ) * S;

% ----------------------------------------------------------------------------
% Damped-Newton (i.e. Levenberg-like) non-linear optimization method

function [X,M,S,C,RMSE] = pgGaussNewton( W, D, K, d, numIter, RMSE_TOL )

VALID = isfinite(W);             % mask of available data
                                 % (missing data marked as NaN in W)

[T,n] = size(W); T = T / 2;      % number of frames (images) and points
X     = eye(d,K);                % deterministic initialization of X
Od    = idct( eye(T,d) );        % DCT basis vectors
Bnr   = D * kronmex(Od,eye(3));  % basis for kronmex(X,eye(3))

V = sparse( pgVecAxI(d,K,3) );   % mapping matrix: vec(kron(X,I3)) = V vec(X)

% Auxiliary variables
nx  = K*d;                       % translation and shape DCT series
Id  = speye(nx);                 % damping matrix
delta = 1.0e-04;                 % initial damping parameter
g   = zeros(nx,1);               % gradient vector
H   = zeros(nx);                 % Hessian matrix

% Compute initial factors
R = zeros( size(W) );            % residual values
S = zeros(3*K, n);
M = D * kronmex( Od*X, eye(3) );
for j = 1:n
    mask = VALID(:,j);
    Mj = M(mask,:);
    wj = W(mask,j);
    S(:,j) = pinv(Mj) * wj;
    R(mask,j) = wj - Mj * S(:,j);
end

% Initial 2D fit error (initial cost of f(M))
RMSE = zeros(numIter+1,1);
RMSE(1) = sqrt(nanmean(R(:).^2));
fprintf('\n\ni = 0 \t RMSE = %-9.6f \n', RMSE(1) )

% Main loop
%warning('off', 'MATLAB:nearlySingularMatrix');     % OK! Damping fixes Hessian

for iter = 1:numIter
    
    % (1) calculate Gradient and Jacobian (J'J) approx to Hessian (Gauss-Newton)
    g(:) = 0; H(:) = 0;
    for j = 1:n
        mask = VALID(:,j);
        Mj   = M(mask,:);
        
        PjBnrj = Bnr(mask,:) - Mj*( pinv(Mj) * Bnr(mask,:));
        Jj = kronmex( S(:,j)', PjBnrj ) * V;
        
        g  = g - (R(mask,j)' * Jj)';
        H  = H + Jj'*Jj;
    end
    % Make H symmetric
    H = (H + H') * 0.5;
   
    % (2) Repeat solving for vec_dX until f(X+dX) < f(X) or converged
    while true 
        vec_dX = pinv(H + delta*Id) * g;
        %vec_dX = (H + delta*Id) \ g;
        newX   = X - reshape( vec_dX, [], K );
        
        % Orthonormalize newX for numerical stability (newX is non-unique)
        [newX,foo] = qr(newX, 0);
        
        % Compute new factors
        M = D * kronmex( Od*newX, eye(3) );
        for j = 1:n
            mask = VALID(:,j);
            Mj = M(mask,:);
            wj = W(mask,j);
            S(:,j) = pinv(Mj) * wj;
            R(mask,j) = wj - Mj * S(:,j);
        end
        
        % Evaluate cost f(newx)
        R2 = R.^2;
        max_err = sqrt(nanmax( R2(:) ));
        RMSE(iter+1) = sqrt(nanmean( R2(:) ));
        
         % damping termination tests
        if (RMSE(iter+1) < RMSE(iter)), OK = true; break, end
        
        % line search book-keeping...
        delta = delta * 10;
        if (delta > 1.0e30), OK = false; break, end
    end                                                            % end while
    % Error test (bailed out with no descent)
    if (~OK), disp('Error: cannot find descent direction!'), break, end
    
    % (3) Book-keeping; display new errors
    delta = max( delta / 100, 1.0e-20 );
    X = newX;
    
    % (5) Display new error and test convergence
    fprintf('i = %-4d  RMSE = %-9.6f (max %-9.6f)  l = 1.0e%03d \n', ...
             iter, RMSE(iter+1), max_err, fix(log10(delta)) )
                  
    if (iter > 1 && RMSE(iter-1) - RMSE(iter+1) < RMSE_TOL)
        disp('Converged!'), break
    end
end
%warning('on', 'MATLAB:nearlySingularMatrix');
C = Od*X;

% Truncate vector of RMSE values
RMSE = RMSE(1:iter);
if (iter == numIter), disp('Stopped: max # iterations.'), end

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

Kmn = zeros(na,na);                                          % MAKE IT SPARSE?
for row = 1:na
    Kmn(row, Pos(row)) = 1;
end
% ----------------------------------------------------------------------------
