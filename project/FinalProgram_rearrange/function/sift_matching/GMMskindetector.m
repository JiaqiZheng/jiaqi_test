function [ output_args ] = untitled( video_color )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% THIS IS AN ABANDONED VERSION

%% using fixed GMM 
% The model in the Statistical Color Model with an Application in Skin
% Detection.
[ GMM_skin, GMM_nonskin ] = getGMM();

%% skin detection using the fitted GMM
image = video_color(:,:,:,20);
im = imresize(image,0.25);
im_vect = im(:);

im = imvector;
[H,W,~] = size(im);
LRimage = zeros(size(im,1),size(im,2));
h = waitbar(0);

for x = 1:1:W
    for y = 1:1:H
        waitbar(((x-1)*H+y)/(H*W),h)
        
        colorpixel = impixel(im,x,y); % red, green, blue
        likelihood_skin = calculateLikelihood( colorpixel, GMM_skin, 'mine');
        likelihood_nonskin = calculateLikelihood( colorpixel, GMM_nonskin,'mine' );
        likelihoodratio = likelihood_skin/likelihood_nonskin;
        LRimage(y,x) = likelihoodratio;
        
    end
end

image = imresize(LRimage,4);

end

