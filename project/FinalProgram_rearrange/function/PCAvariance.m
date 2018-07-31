function [ PCvector, PCFeatures ] = PCAvariance( DataMatrix, ratio )
% apply the PCA on the DataMatrix and hold the principle components that
% corresponding to large variance and preserve ration*total variance

% PCA on the original training data
[COEFF, SCORE, LATENT] = pca(DataMatrix);
% select PCs that preserve 99% of variance
PreseveVariance = 0;
NumPC = 0;
while PreseveVariance < ratio
    NumPC = NumPC + 1;
    PreseveVariance = sum(LATENT(1:NumPC))/sum(LATENT);
end

PCFeatures = SCORE(:,1:NumPC);
PCvector = COEFF(:,1:NumPC);

end

