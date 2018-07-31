function [ kalmanresult, s_post, P_post ] = kalmanfilter( testIndex, xLast, sigma_v, phi, s_post, P_post, initial, mode )
%   Summary of this function goes here
%   Apply the kalman filter on the input.
%   
%   by Feng, Qianli, May, 2015
%   
%   Detailed explanation goes here
%   Input arguments: 1. testIndex: is the loop index, indicating which loop 
%                           the program is in.
%                    2. xLast: is the detection result from the gibbs
%                           sampling. The input from other application should also be fine.
%                    3. sigma_v: is the variance parameter of the error of 
%                           the dynamic model. If the dynamic model is "constant"
%                           acceleration, then the sigma_v is the variance of the
%                           acceleration (it is supposed to be a zero-mean
%                           gaussian varaible, the "constant" means that in
%                           the model it should be a constant, however
%                           there might be some variation). Please note
%                           that this parameter is NOT the covariance of
%                           the model, which appear in the equation in the
%                           Kalman filter. It is a (mutilpication)factor of
%                           the covariance.
%                    4. phi: is the variance parameter of error of the 
%                           measurement in the Kalman filter.
%                    5. model: is the arguments to choose dynamic models.
%                           So far there are only two models:
%                               2 - the constant acceleration(2nd derivative) model
%                               4 - the constant forth derivative model
%                           more work should be added here.
% Output arguments:  1. kalmanresult: is the result of kalman filter,
%                           should be the same size as the input xLast

%% initialization of kalman filter
t = 0.55;
% sigma_v is the parameter of the process noise covariance, the larger the
% sigma is, the greater the covariance matrix is. 
% sigma_v = 4;
% phi is the parameter of the measurement noise covariance, similar to the
% signma_v.
% phi = 5;
    
if mode == 2                   % the constant acceleration model.
   
    % state transition matrix (dynamic model).
    A = [1 0 t 0 0.5*t^2 0;...
         0 1 0 t 0 0.5*t^2;...
         0 0 1 0 t 0;...
         0 0 0 1 0 t;...
         0 0 0 0 1 0;...
         0 0 0 0 0 1];
    % measurment matrix.
    H = [1 0 0 0 0 0;...
         0 1 0 0 0 0]; 
    % process noise covariance.
    Q = [0.25*t^4 0 0.5*t^3 0 0.5*t^2 0;...
         0 0.25*t^4 0 0.5*t^3 0 0.5*t^2;...
         0.5*t^3 0 t^2 0 t 0;...
         0 0.5*t^3 0 t^2 0 t;...
         0.5*t^2 0 t 0 1 0;...
         0 0.5*t^2 0 t 0 1]*sigma_v^2;
    % covariance matrix of the error of measurement.
     R = [phi 0;
         0 phi];

    extraMat = zeros(4,size(xLast,2));
    z_current = [xLast;extraMat];

elseif mode == 4                % of the constant 4th derivative model.
    
    % state transition matrix (dynamic model) 
    A = [1 0 t 0 0.5*t^2 0 1/6*t^3 0 1/24*t^4 0;...
         0 1 0 t 0 0.5*t^2 0 1/6*t^3 0 1/24*t^4;...
         0 0 1 0 t 0 0.5*t^2 0 1/6*t^3 0;...
         0 0 0 1 0 t 0 0.5*t^2 0 1/6*t^3;...
         0 0 0 0 1 0 t 0 0.5*t^2 0;...
         0 0 0 0 0 1 0 t 0 0.5*t^2;...
         0 0 0 0 0 0 1 0 t 0;...
         0 0 0 0 0 0 0 1 0 t;...
         0 0 0 0 0 0 0 0 1 0;...
         0 0 0 0 0 0 0 0 0 1];
    % measurment matrix.
    H = [1 0 0 0 0 0 0 0 0 0;...
         0 1 0 0 0 0 0 0 0 0]; 
    % process noise covariance.
    Q_half = [(1/24*t^4)^2 0 1/24*1/6*t^7 0 1/24*1/2*t^6 0 1/24*t^5 0 1/24*t^4 0;...
              0 (1/24*t^4)^2 0 1/24*1/6*t^7 0 1/24*1/2*t^6 0 1/24*t^5 0 1/24*t^4;...
              0 0 (1/6*t^3)^2 0 1/12*t^5 0 1/6*t^4 0 1/6*t^3 0;...
              0 0 0 (1/6*t^3)^2 0 1/12*t^5 0 1/6*t^4 0 1/6*t^3;...
              0 0 0 0 (1/2*t^2)^2 0 1/2*t^3 0 1/2*t^2 0;...
              0 0 0 0 0 (1/2*t^2)^2 0 1/2*t^3 0 1/2*t^2;...
              0 0 0 0 0 0 t^2 0 t 0;...
              0 0 0 0 0 0 0 t^2 0 t;...
              0 0 0 0 0 0 0 0 1 0;...
              0 0 0 0 0 0 0 0 0 1]*sigma_v^2;
    Q = Q_half' + Q_half - (Q_half'.*Q_half).^0.5;
    % covariance matrix of the error of measurement.
    R = [phi 0;
         0 phi];
     
    extraMat = zeros(8,1);
    z_current = [xLast;extraMat];
    
end





%% 
if testIndex == 1
    % initialize at origin
    if isempty(xLast)
        z_current = [initial';extraMat];
    end
    
    s_post(1) = struct('result',z_current);
    % let's set the initial error of the state(z_current) is 
    P_post(1) = struct('EstimationErrorCovariance',ones(size(Q)));
    kalmanresult = [s_post(testIndex).result(1,:);s_post(testIndex).result(2,:)];
else
    
    % calculate the velocity and acceleration
%     velocity = (xLast - s_post(testIndex-1).result(1:2,:))/t;
%     acceleration = (velocity - s_post(testIndex-1).result(3:4,:))/t;
%     z_current = xLast;

    % prediction stage
    s_prior = A*s_post(testIndex-1).result;
    P_prior = A*P_post(testIndex-1).EstimationErrorCovariance*A' + Q;

    % correction stage
    K_current = P_prior*H'*(H*P_prior*H' + R)^(-1);
    if ~isempty(xLast)
        s_post_current = s_prior + K_current*(xLast - H*s_prior);
    else
        s_post_current = s_prior;
    end
    s_post(testIndex) = struct('result',s_post_current);
    P_post_current = (eye(size(K_current*H)) - K_current*H)*P_prior;
    P_post(testIndex) = struct('EstimationErrorCovariance',P_post_current);

    kalmanresult = [s_post(testIndex).result(1,:);s_post(testIndex).result(2,:)];
    % save ([outFolder '/' resultList(i).name],'testImage', 'kalmanresult');

end

end

