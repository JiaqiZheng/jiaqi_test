
function [M,S,x,rmse,iter] = pgCSF_Bwp ( W, x, d, numIter, RMSE_TOL, verbose )
%function [M,S,x,rmse,iter] = pgCSF_Bwp ( W, x, d, numIter, RMSE_TOL, verbose )
%
% Direct factorization of Euclidean cameras/shape in rigid structure from motion
%
% By Paulo Gotardo
%
% Inputs:
%
% W is the observation matrix (missing data encoded as NaN entries)
% x is a cell array with the initial DCT coefficients { x1, x2, x3, x4, x5 }
% d is the number of DCT basis vectors used for each xi
% numIter is the maximum number of iterations
% RMSE_TOL is the parameter of the stopping (convergence) rule
% verbose is boolean
%
pgCheckBuildKronmex()

VALID = isfinite(W);      % mask of available observations
T = size(W,1) / 2;

if (nargin < 6), verbose = false; end
if (nargin < 5), RMSE_TOL = 1.0e-6; end
if (nargin < 4), numIter = 250; end
if (nargin < 3), d = T; end
if (nargin < 2 || isempty(x))
    % x1, x2, x3, x4, x5
    x = cell(5,1);
    x{1} = [ 0 0 ]'; % alpha
    x{2} = [ 0 1 ]'; % beta
    x{3} = [ 0 0 ]'; % gamma
    x{4} = [ 1 0 ]'; % lambda
    x{5} = [ 0 0 ]'; % t
end

[M,S,x,rmse,iter] = pgGaussNewton( W, VALID, x, d, numIter, RMSE_TOL, verbose );

% ----------------------------------------------------------------------------
% Damped Gauss-Newton (i.e. Levenberg-like) non-linear optimization method

function [M,S,x,rmse,iter] = pgGaussNewton (W, VALID, x, d, numIter, RMSE_TOL, verbose )

[T,n] = size(W); T = T / 2;      % number of frames and points

% Enlarge parameter vectors if necessary (if adding more DCT basis vectors)
for i = 1:4
    if (numel(x{i}) < d), x{i}(d) = 0; end
    if (numel(x{i}) > d), x{i} = x{i}(1:d); end
end
if (numel(x{5}) < 2*d), x{5}(2*d) = 0; end
if (numel(x{5}) > 2*d), x{5} = x{5}(1:2*d); end

% Auxiliary variables
nr  = 4*d;                        % number of variables in rotation matrices
nt  = 2*d;                        % number of variables in translation vectors
nx  = nr+nt;
Id  = speye(nx);                  % damping matrix
delta = 1e-4;                     % initial damping parameter

g   = zeros(nx,1);                % gradient vector
H   = zeros(nx);                  % Hessian matrix
I2T = speye(2*T);                 % sparse identitity matrix 2Fx2F
Od   = idct( eye(T,d) );           % DCT basis with d frequency components
Baf = kronmex(Od,eye(2));          % basis for t

% Compute initial factors
R = zeros( size(W) );             % residual values
S = zeros(3, n);
M = pgGetAllRs (x, Od);
t = Baf * x{5};

for j = 1:n
    mask = VALID(:,j);
    Mj = M(mask,:);
    Wjc = W(mask,j) - t(mask);
    S(:,j) = Mj \ Wjc;
    R(mask,j) = Wjc - Mj * S(:,j);
end

% Compute initial 2D fit error (initial cost f(M,t))
RMSE = zeros(numIter+1,1);
RMSE(1) = sqrt(nanmean( R(VALID(:)).^2 ));
if (verbose)
    fprintf('\n\ni = 0 \t RMSE = %-9.6f \n', RMSE(1) )
end

% Main loop
warning('off', 'MATLAB:nearlySingularMatrix');     % OK! Damping fixes Hessian

for iter = 1:numIter
    
    % (1) calculate Gradient and Jacobian (J'J) approx to Hessian (Gauss-Newton)
    g(:) = 0; H(:) = 0;
    
    % Update local basis in the smooth parameter manifold
    [Ba,Bb,Bc,Bl] = pgGetAlldRs (x, Od);                % compute blocks in Bwp
    Bwp = [Ba,Bb,Bc,Bl];
    
    for j = 1:n
        mask = VALID(:,j);
        Mj   = M(mask,:);     
        PIj  = I2T(mask,:);
                
        %PjpPIj = PIj - Mj * ( Mj \ PIj );
        %Jj = [ kronmex( S(:,j)', PjpPIj )*[Ba Bb Bc Bl]  PjpPIj*Baf ];
        
        SjxPIj = [S(1,j)*PIj S(2,j)*PIj S(3,j)*PIj];
        Jj0 = [ SjxPIj*Bwp Baf(mask,:) ];
        Jj  = Jj0 - Mj * (Mj \ Jj0);
        
        rj = R(mask,j);
        g = g - (rj' * Jj)';
        H = H + Jj'*Jj;
    end
    H = (H + H') * 0.5;                % enforce symmetry of H
    
     % (2) Repeat solving for vec_dX until f(X-dX) < f(X) or converged
    while true        
        vec_dx = (H + delta*Id) \ g;
        dx = mat2cell( vec_dx, [ d d d d 2*d ], 1 );
        newx = cellfun(@(a,b)(a-b), x, dx, 'UniformOutput', false);
        
        %newx{4} = newx{4} / newx{4}(1);
        
        % Compute new factors
        M = pgGetAllRs (newx, Od);
        t = Baf * newx{5};
        for j = 1:n
            mask = VALID(:,j);
            Mj = M(mask,:);
            Wjc = W(mask,j) - t(mask);        
            S(:,j) = Mj \ Wjc;
            R(mask,j) = Wjc - Mj * S(:,j);
        end
        
        % Evaluate cost f(newx)
        R2 = R(VALID(:)).^2;
        max_err = sqrt(nanmax( R2 ));
        RMSE(iter+1) = sqrt(nanmean( R2 ));
        
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
    x = newx;
    
    % (4) Display new error and test convergence
    if (verbose)
        fprintf('i = %-4d  RMSE = %-9.6f (max %-9.6f)  l = 1.0e%03d \n', ...
                iter, RMSE(iter+1), max_err, fix(log10(delta)) )
    end
    if (RMSE(iter) - RMSE(iter+1) < RMSE_TOL), break, end
end
warning('on', 'MATLAB:nearlySingularMatrix');

% Normalize t and S
q = mean( S, 2 );
S = S - repmat(q, 1, n);
t = t + M * q;
%x{5} = x{5} - Baf' * t;

M(:,4) = t;
S(4,:) = 1;

% Truncate vector of RMSE values
iter = iter + 1;
rmse = RMSE(iter);

% ----------------------------------------------------------------------------
% Returns 2x3 block of a rotation matrix computed from Euler angles (Z-Y-Z)

function Rs = pgGetAllRs (x, Od)

T = size(Od,1);
Rs = zeros(2*T,3);

alpha = Od * x{1};
beta  = Od * x{2};
gamma = Od * x{3};
scale = Od * x{4};

for t = 1:T
    Rs(2*t-[1 0],:) = pgGetR (alpha(t), beta(t), gamma(t), scale(t));
end

% ----------------------------------------------------------------------------
% Returns 2x3 block of a rotation matrix computed from Euler angles (Z-Y-Z)

function R = pgGetR (alpha, beta, gamma, scale)

ca = cos(alpha); cb = cos(beta); cc = cos(gamma);
sa = sin(alpha); sb = sin(beta); sc = sin(gamma);

R = scale * [ (ca*cb*cc - sa*sc) (-ca*cb*sc - sa*cc) (ca*sb) ; ...
              (sa*cb*cc + ca*sc) (-sa*cb*sc + ca*cc) (sa*sb) ];

% ----------------------------------------------------------------------------
% Compute dRfdx

function [dRfda,dRfdb,dRfdc,dRfdd] = pgGetdR (alpha, beta, gamma, scale)

ca = cos(alpha); cb = cos(beta); cc = cos(gamma);
sa = sin(alpha); sb = sin(beta); sc = sin(gamma);

dRfda = scale*[ (-sa*cb*cc - ca*sc) ( sa*cb*sc - ca*cc) (-sa*sb) ; ...
                ( ca*cb*cc - sa*sc) (-ca*cb*sc - sa*cc) ( ca*sb) ];

dRfdb = scale*[ (-ca*sb*cc        ) (ca*sb*sc         ) ( ca*cb) ; ...
                (-sa*sb*cc        ) (sa*sb*sc         ) ( sa*cb) ];

dRfdc = scale*[ (-ca*cb*sc - sa*cc) (-ca*cb*cc + sa*sc) (   0  ) ; ...
                (-sa*cb*sc + ca*cc) (-sa*cb*cc - ca*sc) (   0  ) ];

dRfdd =       [ ( ca*cb*cc - sa*sc) (-ca*cb*sc - sa*cc) ( ca*sb) ; ...
                ( sa*cb*cc + ca*sc) (-sa*cb*sc + ca*cc) ( sa*sb) ];

% ----------------------------------------------------------------------------

function [Ba,Bb,Bc,Bl] = pgGetAlldRs (x, Od)

[T,d] = size(Od);
Ba = zeros(6*T,d); Bb = Ba; Bc = Ba; Bl = Ba;

alpha  = Od * x{1};
beta   = Od * x{2};
gamma  = Od * x{3};
lambda = Od * x{4};

for t = 1:T
    [da,db,dc,dl] = pgGetdR( alpha(t), beta(t), gamma(t), lambda(t) );
    
    rows = [ 2*t-[1 0] 2*(t+T)-[1 0] 2*(t+T+T)-[1 0] ];
    Ot = Od(t,:);

    Ba(rows,:) = da(:) * Ot;
    Bb(rows,:) = db(:) * Ot;
    Bc(rows,:) = dc(:) * Ot;
    Bl(rows,:) = dl(:) * Ot;
% Ba(rows,:) = kronmex( da(:), Ot );
% Bb(rows,:) = kronmex( db(:), Ot );
% Bc(rows,:) = kronmex( dc(:), Ot );
% Bl(rows,:) = kronmex( dl(:), Ot );
end

% ----------------------------------------------------------------------------
