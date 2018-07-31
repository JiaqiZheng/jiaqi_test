function [state,reason] = IsLegitVideo(video_color)
% decide whether the video is satisfied the assumption of the algorithm
% 1. total number of skin color pixel criterion: if the total number of
% skin pixels is larger than the number of skin pixels in the face. Discard
% the video.
numFrames = size(video_color,4);

%% face detection
% to prevent the occasionly false positive, only consider the frame
% sequence that stablely contains face detected (10 frames contains faces consecutively).
faceFrameNum = 0;
for frameIdx = 1:1:numFrames
    boxes = facedetector(video_color(:,:,:,frameIdx),false);
    
    % consider if there is 10 frames contains faces consecutively
    if ~isempty(boxes) 
        faceFrameNum = faceFrameNum + 1;
    else
        faceFrameNum = 0;
    end
    
    if faceFrameNum == 4 || frameIdx > numFrames
        break
    end
    
end

if faceFrameNum == 0
    state = false;
    reason = 'no face detected.';
    return
else
    state = true;
    reason = [];
end

%% if the number of total skin pixels are 2 times more than the number of face skin color pixels
% skin color pixel detection

% load('./GMMdata/GMM_5000nonskin4.mat');
% GMM_skin = GMM_skin_struct{4};
% GMM_nonskin = GMM_nonskin_struct{4};
%

% load('./GMMdata/GMM_5000skin4.mat');
% load('./GMMdata/GMM_5000nonskin4.mat');
% threshGMM = 0.8; %3.2;
% [ video_bw ] = SkinDetectorGMM( video_color, GMM_skin, GMM_nonskin, threshGMM, 'all' );
% 
% 
% load('./GMMdata/GMM_13000skin6DB4.mat');
% load('./GMMdata/GMM_23000nonskin4.mat');
% threshold = 1.8;
% weight = 0.5;
% [ video_bw ] = SkinDetectorGMMFace( video_color, GMM_skin, GMM_nonskin, threshold, weight, 'all');


% % figure;imshow(video_bw);
% %% get the number of skin pixels inside the face bounding box
% numSkinPixelTotal = sum(sum(video_bw));
% faceBBmaskCell = GetFaceSkinPixelNum(video_bw,boxes);
% numSkinPixelFace = sum(sum(faceBBmaskCell{1}));
% 
% %% if the number of total skin pixels are 2 times more than the number of face skin color pixels
% if numSkinPixelTotal > 4*numSkinPixelFace;
%     state = false;
%     reason = 'skin-color like background';
% else
%     state = true;
%     reason = [];
% end


end