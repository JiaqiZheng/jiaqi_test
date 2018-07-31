%% THIS IS AN ABANDONED VERSION

function [ likelihood ] = calculateLikelihood( colorpixel, GMM, method )
%Calculate the likelihood of belonging to the model that GMM modeled.
%   Detailed explanation goes here
if strcmp(method,'matlab')
    num = GMM.NComponents;
    colorpixel = repmat(colorpixel,num,1);

    % calculate the likelihood ratio of a pixel being skin-color 
    weights_all = GMM.PComponents;
    mean_all = GMM.mu;
    cov_all = zeros(3,3,num);

    cov_all(1,1,:) = GMM.Sigma(:,1);
    cov_all(2,2,:) = GMM.Sigma(:,2);
    cov_all(3,3,:) = GMM.Sigma(:,3);

    likelihood = weights_all' * mvnpdf(double(colorpixel),mean_all,cov_all);

elseif strcmp(method,'mine')
    num = GMM.NumComponents;
    colorpixel = repmat(colorpixel,num,1);
    weights_all = GMM.ComponentProportion;
    mean_all = GMM.mu;
    cov_all = zeros(3,3,num);

    cov_all(1,1,:) = GMM.sigma(:,1);
    cov_all(2,2,:) = GMM.sigma(:,2);
    cov_all(3,3,:) = GMM.sigma(:,3);
    
    XminusMean = double(colorpixel) - mean_all;
    prob = zeros(num,1);
    
    % calculate the probability
    for i = 1:1:num
        Mdistance = XminusMean(i,:)*(cov_all(:,:,i)^-1)*XminusMean(i,:)';
        prob(i) = (exp(-0.5*Mdistance))/(det(cov_all(:,:,i))^0.5);
    end
    
    likelihood = prob'*weights_all;
elseif strcmp(method,'matlabpdf')
    tic
    likelihood2 = pdf_gmm(GMM_skin2,double(imvector));
    likelihood3 = pdf_gmm(GMM_nonskin2,double(imvector));
    likelihoodratio2 = likelihood2./likelihood3;
    toc
end

end

