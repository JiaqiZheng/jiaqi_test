
function [M,S,X,rmse,iter] = pgCSFmean ( W, r, X0, numIter, RMSE_TOL, verbose, B )
%function [M,S,X,rmse,iter] = pgCSFmean ( W, r, X0, numIter, RMSE_TOL, verbose, B )
%
% Outputs "extended" factors, [ M t ], and [ S ; 1 ], with W = MS
%
% By Paulo Gotardo
%
% Inputs:
%
% W is the observation matrix (missing data encoded as NaN entries)
% r is the factorization rank
% X0 is the initial value of X (or the initial M0 when basis B is the identity)
% numIter is the maximum number of iterations
% RMSE_TOL is the parameter of the stopping (convergence) rule
% verbose is boolean
% B is the basis of M = BX (default basis is the identity matrix)
%
pgCheckBuildKronmex()

if (nargin < 7), B = eye(size(W,1)); end  % assume canonical basis I_m

% Auxiliary variables
VALID = isfinite(W);                 % mask of available observations
                                     % (missing data marked as NaN in W)
n = size(W,2);                       % number of points
d = size(B,2);                       % number of DCT basis vectors
nx  = d*r;                           % number of unknowns
Idr = speye(nx);                     % damping matrix
delta = 1e-4;                        % initial damping parameter
g   = zeros(nx,1);                   % gradient vector
H   = zeros(nx,nx);                  % Hessian matrix

% Initialize X
if isempty(X0)
    X = [ eye(r,r) ; zeros(d-r,r) ]; % deterministic initialization
    X(:,end) = 0;                    % initialize mean column vector as t = 0
else
    X = X0;
    if (size(X,1) < d), X(d,:) = 0; end  % enlarge
end

% Compute initial factors
M = B*X;                             % current estimate of M
S = zeros(r-1,n);                    % current estimate of S
R = zeros(size(W));                  % residual values
for j = 1:n
    mask = VALID(:,j);
    Mj = M(mask,1:end-1);
    tj = M(mask,end);
    wj = W(mask,j) - tj;
    %S(:,j) = pinv(Mj) * wj;
    S(:,j) = Mj \ wj;
    R(mask,j) = wj - Mj * S(:,j);
end

% Compute initial fit error (initial cost f(X))
rmse = zeros(numIter+1,1);          % error at each iteration
rmse(1) = sqrt(nanmean( R(VALID(:)).^2 ));
if (verbose)
    fprintf('\n\ni = 0 \t RMSE = %-15.10f \n', rmse(1) )
end

% Main loop
warning('off', 'MATLAB:nearlySingularMatrix');

for iter = 1:numIter
    
    % (1) calculate Gradient and Jacobian (J'J) approx to Hessian (Gauss-Newton)
    g(:) = 0; H(:) = 0;
    for j = 1:n
        mask = VALID(:,j); 
        Mj = M(mask,1:end-1);
        Bj = B(mask,:);
        sj = S(:,j);
        rj = R(mask,j);        
        
        %PjBj = Bj - Mj * (pinv(Mj)*Bj);            % (I-Pj)*Bj
        PjBj = Bj - Mj * (Mj\Bj);                  % (I-Pj)*Bj
        Jj = kronmex([ sj' 1 ], PjBj);
                
        g = g - (rj' * Jj)';
        H = H + Jj'*Jj;
    end
    H = 0.5 * (H + H');                            % force H symmetric
    
     % (2) Repeat solving for vec_dX until f(X-dX) < f(X) or converged
    while true
        %vec_dX = pinv(H + delta*Idr) * g;
        vec_dX = (H + delta*Idr) \ g;
        newX = X - reshape(vec_dX, d, r);
        [Q,foo] = qr( newX(:,1:end-1) ,0);
        newX(:,1:end-1) = Q;
        
        % Compute new factors
        M = B * newX;
        for j = 1:n
            mask = VALID(:,j);
            Mj = M(mask,1:end-1);
            tj = M(mask,end);
            wj = W(mask,j) - tj;
            %S(:,j) = pinv(Mj) * wj;
            S(:,j) = Mj \ wj;
            R(mask,j) = wj - Mj * S(:,j);
        end
                
        % Evaluate cost f(newX)
        R2 = R(VALID(:)).^2;
        max_err = sqrt(nanmax( R2(:) ));
        rmse(iter+1) = sqrt(nanmean( R2(:) ));
                
        % Damping termination tests
        if (rmse(iter+1) < rmse(iter)), OK = true; break, end
        
        % Continue damping of H?
        delta = delta * 10;
        if (delta > 1.0e30), OK = false; break, end
    end                                                            % end while
    % Error test (bailed out with no descent)
    if (~OK), disp('Error: cannot find descent direction!'), break, end
    
    % (3) Book-keeping; display new errors
    delta = max( delta / 100, 1.0e-20);
    X = newX;
    
%     % Normalize t and S
%     q = mean( S, 2 );
%     S = S - repmat(q, 1, n);
%     M(:,end) = M(:,end) + M(:,1:end-1) * q;
%     X(:,end) = B' * M(:,end);
    
    % (4) Display new error and test convergence
    if (verbose)
        disp(sprintf('i = %-4d  RMSE = %-9.6f (max %-9.6f)  l = 1.0e%03d', ...
                      iter, rmse(iter+1), max_err, fix(log10(delta)) ))
    end                 
    if (rmse(iter) - rmse(iter+1) < RMSE_TOL), break, end
end

% Normalize t and S
q = mean( S, 2 );
S = S - repmat(q, 1, n);
M(:,end) = M(:,end) + M(:,1:end-1) * q;
%X(:,end) = B' * M(:,end);

% Concatenate row-vector of 1s to S so that W = MS
S = [ S ; ones(1,n) ];

% Truncate vector of RMSE values
iter = iter + 1;
rmse = rmse(iter);

warning('on', 'MATLAB:nearlySingularMatrix');
% ----------------------------------------------------------------------------
