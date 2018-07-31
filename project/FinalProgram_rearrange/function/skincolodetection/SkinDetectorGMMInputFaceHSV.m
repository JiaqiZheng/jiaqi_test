function [ imagemat_bw ] = SkinDetectorGMMInputFaceHSV( video_color, GMM_skin, GMM_nonskin, faceBBs, threshold, weight, show )
%Detect skin by using Gaussian Mixture Models and face pixel distributions
%   Inputs:
%       Videoframes_color is a H-W-3-N matrix which contains N frames of the
%                       video in RGB colorspace. 
%       GMM_skin is the Mixture of Gaussians model of skin color
%       GMM_nonskin is the Mixture of Gaussians model of non skin color
%       threshold is the threshold of the likelihood ratio
%       faceBBs is the matrix saving the detected face bounding boxes for
%       each frame. Each row is the face bounding box represented by
%       X,Y,H,W. [X,Y] is the coordinate of the upper left corner of the
%       bounding box and H,W is the height and width of the box. The
%       algorithm assume only one box. 
%
% Feng, Qianli, Sep 29, 2015

%% skin detection using the fitted GMM
imagemat_bw = false(size(video_color,1),size(video_color,2),size(video_color,4));
    
%% 
facevector = [];
for frameIdx = 1:1:size(video_color,4)
    image = video_color(:,:,:,frameIdx);
    
    HSV = rgb2hsv(image);
    imvector_H = HSV(:,:,1);
    imvector_H = imvector_H(:);
    imvector_S = HSV(:,:,2);
    imvector_S = imvector_S(:);
    imvector_V = HSV(:,:,3);
    imvector_V = imvector_V(:);
    imvectorHSV = double([imvector_H, imvector_S, imvector_V]);  

    firstBox = faceBBs(frameIdx,:);
    %firstBox = BoxResize(firstBox,0.6);
%     firstBox = uint8(round(firstBox));
%     imshow(image);rectangle('Position',firstBox,'EdgeColor','r');drawnow
    
    faceArea = HSV(firstBox(2):firstBox(2)+firstBox(3),firstBox(1):firstBox(1)+firstBox(3),:);

    % vectorize the face image
    facevector_H = faceArea(:,:,1);
    facevector_H = facevector_H(:);
    facevector_S = faceArea(:,:,2);
    facevector_S = facevector_S(:);
    facevector_V = faceArea(:,:,3);
    facevector_V = facevector_V(:);    
    facevectorThis = double([facevector_H,facevector_S,facevector_V]);
    facevector = [facevector;facevectorThis];
end
% train a 4 components Gaussian Mixtures
% options = statset('MaxIter',1000,'Display','iter','UseParallel',true);
% GMMface = fitgmdist(double(facevector),4,'CovType','full','Replicates',5,'Options',options);
meanFaceLab = mean(facevector(:,1:3));
covFaceLab = cov(facevector(:,1:3));

for frameIdx = 1:1:size(video_color,4)
    %% generic skin color 
    im = video_color(:,:,:,frameIdx);
    
%     im = imresize(image,1);
% 
%     % vectorize the image pixels in RGB color
%     imvector_r = im(:,:,1);
%     imvector_r = imvector_r(:);
%     imvector_g = im(:,:,2);
%     imvector_g = imvector_g(:);
%     imvector_b = im(:,:,3);
%     imvector_b = imvector_b(:);
%     imvectorRGB = double([imvector_r, imvector_g, imvector_b]);   

    
    %% using face area color information
    % vectorize the image pixels in Lab color
    HSV = rgb2hsv(im);
    imvector_H = HSV(:,:,1);
    imvector_H = imvector_H(:);
    imvector_S = HSV(:,:,2);
    imvector_S = imvector_S(:);
    imvector_V = HSV(:,:,3);
    imvector_V = imvector_V(:);
    imvectorHSV = double([imvector_H, imvector_S, imvector_V]);
        
    likelihood_skin = pdf_gmm(GMM_skin,double(imvectorHSV));
    likelihood_nonskin = pdf_gmm(GMM_nonskin,double(imvectorHSV));

    facePdf = mvnpdf(imvectorHSV(:,1:3),meanFaceLab,covFaceLab);
%     facePdf = pdf_gmm(GMMface,double(imvectorLAB));
    
    scaleDiff = mean(facePdf)/mean(likelihood_skin);
    facePdfES = facePdf/scaleDiff; % equal scale compared to likelihood_skin
    
%     image_facePdf = reshape(facePdfES,size(im(:,:,1)));
    %% combining the two methods
%     imagesc(reshape(facePdf,size(im(:,:,1))))

    %     likelihood_nonskin = 1;
    newlikelihood = weight*facePdfES + (1-weight)*likelihood_skin;
    likelihoodratio = (newlikelihood)./(likelihood_nonskin);

    image_lhr = reshape(likelihoodratio,size(im(:,:,1)));

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
    L = length(imvectorHSV);
    
    image_bw = false(size(im,1),size(im,2));
    image_bw(1:L) = bwvector(1:L);
    % fill the holes inside the masks
%     image_bw = imfill(image_bw,'holes');

    % do the dilation and erosion to make the skin mask solid
%     [ image_bw ] = DilateThenErosion( image_bw );
    [ image_bw ] = PostProcessBinaryMask( image_bw, 4 );
    
    imagemat_bw(:,:,frameIdx) = image_bw;
    
    if strcmp(show,'skinmask') || strcmp(show,'all')
        figure(1);
%         subplot(1,4,1);
%         imagesc(image_facePdf);
%         subplot(1,4,2);
%         imagesc(likelihood_skinLAB_image);
%         subplot(1,4,3);
%         imagesc(image_lhr);
%         subplot(1,4,4);
        imagesc(image_bw);
        pause(0.1);
    end
end

end


