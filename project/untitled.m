load('GMM_13000skin6DBHSV4.mat')
load('GMM_23000nonskinHSV4.mat')
videoPath="test.mp4"


v = VideoReader(videoPath);
interval =1;

totalFrameNum = get(v,'numberOfFrames');

    outputFrameIdx = 1;
    for frameIdx = 1:interval:totalFrameNum
        img_temp = read(v,frameIdx);
        video_color(:,:,:,outputFrameIdx) = img_temp;
        video_gray(:,:,outputFrameIdx) = rgb2gray(img_temp);
        outputFrameIdx = outputFrameIdx + 1;
    end

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
end


test_nonskin = reshape(likelihood_nonskin,[480,640])
likelihoodratio = (likelihood_skin)./(likelihood_nonskin);

%% compile and add mexopencv first
[ faceBBs,numFaces ] = FaceDetectionMain( video_color );


imagesc(image_lhr)


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
end

im=reshape(bwvector,[480,640]);
imshow(im)
