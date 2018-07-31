function [ image_bw ] = PostProcessBinaryMask( image_bw, iterNum )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% image_bw = image_bw2;
image_bw = imfill(image_bw,'holes');

% define the Structural Element of the
SE = strel('disk', 1, 4);

% in the first version, just do the dilation two times and then erosion two
% times. Later version can be after removing the the area not on the skin,
% dilation utill the connect area smaller or equal to 3.

for iterIdx = 1:1:iterNum
    image_bw = imerode(image_bw,SE);
end

for iterIdx = 1:1:iterNum
    image_bw = imdilate(image_bw,SE);
end

end

