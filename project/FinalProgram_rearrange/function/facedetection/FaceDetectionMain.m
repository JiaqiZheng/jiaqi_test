function [ boxSizesPost,numFaces ] = FaceDetectionMain( video_color )
% Face detectio main function for AASLIE
% FaceDetectioMain including the viola-jones based face detection and post
% processing

numFrames = size(video_color,4);

%% face detection
faceDetectResult = cell(numFrames,1);
for frameIdx = 1:1:numFrames
    faceDetectResult{frameIdx} = facedetector(video_color(:,:,:,frameIdx),false);    
end

%% post processing of the detection result
[boxSizesPost,numFaces] = GetFaceDetectTimeSeries( faceDetectResult );
% for frameIdx = 1:1:numFrames
%     imshow(video_color(:,:,:,frameIdx));
%     rectangle('Position',boxSizesPost(frameIdx,:),'EdgeColor','g','LineWidth',2);
%     drawnow;
% end


end

