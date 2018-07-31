function [ output_args ] = DenseOpticalFlow( video_gray )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

%% dense optical flow method
numFrames = size(video_gray,3);
figure
for frameIdx = 2:1:numFrames % calculating optical flow requires
    tic
    flow = cv.calcOpticalFlowFarneback(video_gray(:,:,frameIdx-1),video_gray(:,:,frameIdx));

    flowInten = (flow(:,:,1).^2 + flow(:,:,2).^2).^0.5;
    toc
    flowVideo(:,:,frameIdx) = flowInten;
    imagesc(flowInten);
    drawnow;
end

%% 



end

