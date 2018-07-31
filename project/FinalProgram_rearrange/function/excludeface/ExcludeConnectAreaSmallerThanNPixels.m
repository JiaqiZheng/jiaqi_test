function [ NewSkinMask2 ] = ExcludeConnectAreaSmallerThanNPixels( NewSkinMask2,n )
% exclude the connect area smaller or equal than n pixels 
%   Detailed explanation goes here
NewSkinAreaStruct = bwconncomp(NewSkinMask2);

for BlobIdx = 1:1:NewSkinAreaStruct.NumObjects
    if length(NewSkinAreaStruct.PixelIdxList{BlobIdx}) <= n
        NewSkinMask2(NewSkinAreaStruct.PixelIdxList{BlobIdx}) = false;
    end
end

end

