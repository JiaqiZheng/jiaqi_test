function [ image_bw ] = FrameDiff( thisFrameG, lastFrame, thresh )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

frameDiff = double(thisFrameG) - double(lastFrame);
image_bw = abs(frameDiff) > thresh;
[ image_bw ] = ErosionThenDilate( image_bw );
[ image_bw ] = DilateThenErosion( image_bw );


end

