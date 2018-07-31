function [ imagemat_bw ] = SkinDetectorGMM( Videoframes_color, GMM_skin, GMM_nonskin, threshold, show )
%Detect skin by using Gaussian Mixture Models
%   Inputs:
%       Videoframes_color is a H-W-3-N matrix which contains N frames of the
%                       video in RGB colorspace. 
%       GMM_skin is the Mixture of Gaussians model of skin color
%       GMM_nonskin is the Mixture of Gaussians model of non skin color
%       threshold is the threshold of the likelihood ratio
%
% Feng, Qianli, Sep 29, 2015

%% skin detection using the fitted GMM
imagemat_bw = false(size(Videoframes_color,1),size(Videoframes_color,2),size(Videoframes_color,4));

for i = 1:1:size(Videoframes_color,4)
    image = Videoframes_color(:,:,:,i);
    im = imresize(image,1);

    % vectorize the image pixels
    imvector_r = im(:,:,1);
    imvector_r = imvector_r(:);
    imvector_g = im(:,:,2);
    imvector_g = imvector_g(:);
    imvector_b = im(:,:,3);
    imvector_b = imvector_b(:);

    imvector = [imvector_r, imvector_g, imvector_b];
    % imvector_all = zeros(16*length(imvector),3);
    
    % calcualte the likelihood ratio
%     TEST = pdf(GMM_skin,double(imvector));
    likelihood_skin = pdf_gmm(GMM_skin,double(imvector));
    likelihood_nonskin = pdf_gmm(GMM_nonskin,double(imvector));
%     likelihood_nonskin = 1;
    likelihoodratio = (likelihood_skin)./(likelihood_nonskin);
%     likelihoodratio = -log(likelihoodratio);
    % generate logical mask
    bwvector = false(size(likelihoodratio));
    bwvector(likelihoodratio > threshold) = true;
    
    % change the linear binary vector to image mask
    L = length(imvector);
    
    image_bw = false(size(im,1),size(im,2));
    image_bw(1:L) = bwvector(1:L);
    % fill the holes inside the masks
%     image_bw = imfill(image_bw,'holes');

    % do the dilation and erosion to make the skin mask solid
    [ image_bw ] = DilateThenErosion( image_bw );
    
    imagemat_bw(:,:,i) = image_bw;
    
    if strcmp(show,'skinmask') || strcmp(show,'all')
        figure(1);
        imagesc(image_bw);
        pause(0.1);
    end
end

end

