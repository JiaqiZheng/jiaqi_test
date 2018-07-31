videoName = '/eecf/cbcsl/data100/Qianli2/AASLIEforWeb/videoFolderAvi/39/39_M_S_31.avi';

cd('/eecf/cbcsl/data100/Qianli2/AASLIE2/AASLIE/FinalProgram');
addpath(genpath('/eecf/cbcsl/data100/opencv-qianli/mexopencv-2.4'));

[video_color, video_gray] = videoDir2FrameSeq(videoName,'mmread',3);
% videoResize = imresize(video_color(:,:,:,8),0.5);
% [Ims2, Nms2] = Ms2(videoResize,0.3);                   % Mean Shift (color + spatial)
% figure;imshow(Ims2);
% [state,reason] = IsLegitVideo(video_color);

%% load skin color model
load('./GMMdata/GMM_5000skin5.mat');
load('./GMMdata/GMM_5000nonskin6.mat');
% GMM_skin = GMM_skin_struct{4};
% GMM_nonskin = GMM_nonskin_struct{4};
%% face detection
% to prevent the occasionly false positive, only consider the frame
% sequence that stablely contains face detected (10 frames contains faces consecutively).
% numFrames = size(video_color,4);
% faceFrameNum = 0;
% faceVector = [];
% for frameIdx = 1:1:numFrames
%     thisFrame = video_color(:,:,:,frameIdx);
%     boxes = facedetector(thisFrame,false);
%     
%     consider if there is 10 frames contains faces consecutively
%     if ~isempty(boxes) 
%         width = boxes{1}(3); % only use the width since the bounding boxes are square
%         faceImg = thisFrame(boxes{1}(2):1:boxes{1}(2)+width,...
%                             boxes{1}(1):1:boxes{1}(1)+width,...
%                             :);
%         faceVector = [faceVector;reshape(faceImg,size(faceImg,1)*size(faceImg,2),3)];
%     else
%         faceFrameNum = 0;
%     end
%     
%     if faceFrameNum == 4 || frameIdx > numFrames
%         break
%     end
% end
% 
% % get new skin color mixture model
% [idxImg,faceRGB,nonfaceRGB] = KmeansFaceImage( faceVector );
% meanF = mean(faceRGB,1);
% meanDiff = bsxfun(@minus,GMM_skin.mu,meanF);
% 
% for compIdx = 1:1:size(meanDiff,1)
%     mahaDist(compIdx) = meanDiff(compIdx,:) * GMM_skin.Sigma(:,:,compIdx) * meanDiff(compIdx,:)';
% end
% newWeight = GMM_skin.ComponentProportion./mahaDist; % larger the distance smaller the similarity
% newWeight = newWeight/sum(newWeight);
% 
% GMM_skin_this = gmdistribution(GMM_skin.mu,GMM_skin.Sigma,newWeight);

%%
figure;
numFrames = size(video_color,4);
for frameIdx = 1:1:numFrames
    threshold = 0.9;
    thisFrame = video_color(:,:,:,frameIdx);
    [ video_bw_skin ] = SkinDetectorGMM( thisFrame, GMM_skin, GMM_nonskin, threshold, false);
    
    thisFrameG = video_gray(:,:,frameIdx);
    if frameIdx == 1
        lastFrame = thisFrameG;
    end
    
    image_bw = FrameDiff( thisFrameG, lastFrame, 6);
    lastFrame = thisFrameG;
    
    image_bw_final = video_bw_skin & image_bw;
    
    imshow(video_bw_skin);
end

%%
figure;
lastFrame = zeros(size(thisFrame));
numFrames = size(video_color,4);
for frameIdx = 1:1:numFrames
    threshold = 0.9;
    thisFrame = video_gray(:,:,frameIdx);
    frameDiff = double(thisFrame) - double(lastFrame);
    image_bw = abs(frameDiff)>7;
    [ image_bw ] = ErosionThenDilate( image_bw );
    [ image_bw ] = DilateThenErosion( image_bw );
    imagesc(image_bw);
    lastFrame = thisFrame;
    pause(0.3)
end



