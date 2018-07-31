function [ imagemat_bw ] = SkinDetectorGMMFace( Videoframes_color, GMM_skin, GMM_nonskin, threshold, weight, show )
%Detect skin by using Gaussian Mixture Models and face pixel distributions
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
    %% generic skin color 
    image = Videoframes_color(:,:,:,i);
    
    im = imresize(image,1);

    % vectorize the image pixels in RGB color
    imvector_r = im(:,:,1);
    imvector_r = imvector_r(:);
    imvector_g = im(:,:,2);
    imvector_g = imvector_g(:);
    imvector_b = im(:,:,3);
    imvector_b = imvector_b(:);
    imvectorRGB = double([imvector_r, imvector_g, imvector_b]);   
    
    likelihood_skin = pdf_gmm(GMM_skin,double(imvectorRGB));
    likelihood_nonskin = pdf_gmm(GMM_nonskin,double(imvectorRGB));
    
    %% using face area color information
    % vectorize the image pixels in Lab color
    LAB = rgb2lab(im);
    imvector_L = LAB(:,:,1);
    imvector_L = imvector_L(:);
    imvector_A = LAB(:,:,2);
    imvector_A = imvector_A(:);
    imvector_B = LAB(:,:,3);
    imvector_B = imvector_B(:);
    imvectorLAB = double([imvector_L, imvector_A, imvector_B]);  
    
    boxes = facedetector(im,false);
    if ~isempty(boxes)
        firstBox = boxes{1};
        firstBox = BoxResize(firstBox,0.6);

        faceArea = LAB(firstBox(2):firstBox(2)+firstBox(3),firstBox(1):firstBox(1)+firstBox(3),:);

        % vectorize the face image
        facevector_L = faceArea(:,:,1);
        facevector_L = facevector_L(:);
        facevector_A = faceArea(:,:,2);
        facevector_A = facevector_A(:);
        facevector_B = faceArea(:,:,3);
        facevector_B = facevector_B(:);    
        facevector = double([facevector_L,facevector_A,facevector_B]);

        meanFaceLab = mean(facevector(:,1:3));
        covFaceLab = cov(facevector(:,1:3));
    end
%     mahaD = mahalanobisDist( imvectorLAB(:,2:3), meanFaceLab, covFaceLab );
    facePdf = mvnpdf(imvectorLAB(:,1:3),meanFaceLab,covFaceLab);
    
    scaleDiff = mean(facePdf)/mean(likelihood_skin);
    facePdfES = facePdf/scaleDiff; % equal scale compared to likelihood_skin

    %% combining the two methods
%     imagesc(reshape(newlikelihood,size(im(:,:,1))))

    %     likelihood_nonskin = 1;
    newlikelihood = weight*facePdfES + (1-weight)*likelihood_skin;
    likelihoodratio = (newlikelihood)./(likelihood_nonskin);

%     imagesc(reshape(likelihoodratio,size(im(:,:,1))))

    bwvector = false(size(likelihoodratio));
    bwvector(likelihoodratio > threshold) = true;
    
%     % calcualte the likelihood ratio
%     likelihood_skin = pdf_gmm(GMM_skin,double(imvectorRGB));
%     likelihood_nonskin = pdf_gmm(GMM_nonskin,double(imvectorRGB));
% %     likelihood_nonskin = 1;
%     likelihoodratio = (likelihood_skin)./(likelihood_nonskin);
% %     likelihoodratio = -log(likelihoodratio);
%     % generate logical mask
%     bwvector = false(size(likelihoodratio));
%     bwvector(likelihoodratio > threshold) = true;
    
    % change the linear binary vector to image mask
    L = length(imvectorRGB);
    
    image_bw = false(size(im,1),size(im,2));
    image_bw(1:L) = bwvector(1:L);
    % fill the holes inside the masks
%     image_bw = imfill(image_bw,'holes');

    % do the dilation and erosion to make the skin mask solid
%     [ image_bw ] = DilateThenErosion( image_bw );
    [ image_bw ] = PostProcessBinaryMask( image_bw, 4 );
    
    imagemat_bw(:,:,i) = image_bw;
    
    if strcmp(show,'skinmask') || strcmp(show,'all')
        figure(1);
        imagesc(image_bw);
        pause(0.1);
    end
end

end


