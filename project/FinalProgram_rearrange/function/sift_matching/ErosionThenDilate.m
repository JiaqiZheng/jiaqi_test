function [ SkinMask ] = ErosionThenDilate( SkinMask )
% first dilate and then erosion the binary mask of the skin color mask
%   Skin mask is a binary image where the pixel on skin is 1, not on skin
%   is 0

% define the Structural Element of the
SE = strel('disk', 1, 4);

% in the first version, just do the dilation two times and then erosion two
% times. Later version can be after removing the the area not on the skin,
% dilation utill the connect area smaller or equal to 3.
SkinMask = imerode(SkinMask,SE);
SkinMask = imerode(SkinMask,SE);

% SkinMask = ExcludeConnectAreaSmallerThanNPixels(SkinMask,2);

SkinMask = imdilate(SkinMask,SE);
SkinMask = imdilate(SkinMask,SE);


end

