function [ mahaD ] = mahalanobisDist( X, mu, SIGMA )
% calcualte mahalanobis distance from the mean mu and covariance matrix
% SIGMA; X is a matrix saving the data samples in each row.
mahaD = ones(size(X,1),1);

for i = 1:1:size(X,1)
    mahaD(i) = (X(i,:)-mu)*inv(SIGMA)*(X(i,:)-mu)';
end
end

