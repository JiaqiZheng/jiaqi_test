function [ output_args ] = VideoSmoothing( video_color )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

numFrames = size(video_color,4);
h = size(video_color,1);
w = size(video_color,2);
nC = size(video_color,3); % number of channals

pixelSignal = reshape(video_color,[h*w*nC,numFrames]);
pixelSignalNew = ones(size(pixelSignal));
for sampleIdx = 1:1:size(pixelSignal,1)
    pixelSignalNew(sampleIdx,:) = smooth(double(pixelSignal(sampleIdx,:)),'sgolay',2);
end
video_color_new = reshape(pixelSignalNew,[h,w,nC,numFrames]);
pixelSignalNew = smooth(double(pixelSignal)','sgolay',2);
end
