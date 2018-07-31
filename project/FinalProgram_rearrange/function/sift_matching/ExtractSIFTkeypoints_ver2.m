function [ imgwithsift_structs ] = ExtractSIFTkeypoints_ver2( videoStruct, show, video_num)
% from video structure to sift keypoints
% version 2 changes the video_color and video_gray input into videoStruct,
% which contains the fields of, frames, skinmask and faceBB. 

%% test sift keypoints matching between the standard ASL and the frames of video recording
numFrames = length(videoStruct);

%% calculate the sift keypoints and descriptors of all the frames in the video
sift_structs = cell(1,numFrames);
descriptors = cell(1,numFrames);

extractor = cv.DescriptorExtractor('SURF');
for frameIdx = 1:1:numFrames
    frame_gray = rgb2gray(videoStruct(frameIdx).frames); % change video_gray to frontFrame if using background substraction
    sift_structs{frameIdx} = cv.SIFT(frame_gray);
    descriptors{frameIdx} = extractor.compute(frame_gray,sift_structs{frameIdx});
    
    frame_color = videoStruct(frameIdx).frames;
    if strcmp(show,'originSIFT') || strcmp(show,'all')
        siftwithvideo = cv.drawKeypoints(bsxfun(@times,frame_color,uint8(videoStruct(frameIdx).skinmask)),sift_structs{frameIdx});
        imshow(siftwithvideo);
        pause(0.3);
    end
end

videoStruct = MergeVideoStruct(videoStruct,'sift_keypoints',sift_structs,1:1:size(videoStruct,2));
videoStruct = MergeVideoStruct(videoStruct,'sift_descriptors',descriptors,1:1:size(videoStruct,2));
videoStruct = MergeVideoStruct(videoStruct,'sift_keypoints_full',sift_structs,1:1:size(videoStruct,2));
videoStruct = MergeVideoStruct(videoStruct,'sift_descriptors_full',descriptors,1:1:size(videoStruct,2));
% sift_video = sift_structs_imitat{20};
% videoframe = video_gray(:,:,20); % change video_gray to frontFrame if using background substraction
% siftandvideo = cv.drawKeypoints(videoframe,sift_video);
% imshow(siftandvideo);

%% eliminate outliers and still keypoints
matcher = cv.DescriptorMatcher('BruteForce');

outlier_thresh = inf;  % if the distance(Euclidean squared) of the two matching keypoints is 
stiller_thresh = 10;

for frameIdx = 1:1:numFrames-1
    frame_num1 = frameIdx;
    frame_num2 = frameIdx+1;
    videoStruct = ExtractInterestingKeypoints_ver2...
                    (videoStruct, matcher, frame_num1, frame_num2, outlier_thresh, stiller_thresh, show);
end


%% eliminate the keypoints out of skin

for frameIdx = 1:1:numFrames

    imageStruct = videoStruct(frameIdx);
    
    % find the 8 neighbors of the rounded keypoints pixel, check if there
    % are over half of the neighbors in the skin area
    image_bw = imageStruct.skinmask;
    [ imageStruct2 ] = EliminateKeypointsOutMask_ver2( imageStruct, image_bw, 'all' );
    videoStruct(frameIdx) = imageStruct2;
%     pause(0.1)

end

%% eliminate keypoints on faces
for frameIdx = 1:1:numFrames

    enlarge_ratio = 0.15;
    
    imageStruct = videoStruct(frameIdx);
    faceBB = imageStruct.faceBB;

        
    enlarge_num = round(enlarge_ratio*faceBB(3)); % rectangle(3) is the width or height of the squared face bounding box
    faceBB_enlarge = [faceBB(1)-enlarge_num/2, faceBB(2)-enlarge_num/2, ...
                         faceBB(3)+enlarge_num, faceBB(4)+enlarge_num];

    temp = cell2mat({imageStruct.sift_keypoints{1}.pt}');
    if ~isempty(temp) % it is possible that there is no interesting keypoints in a frame
        faceindex = find(temp(:,1) >= faceBB_enlarge(1) & temp(:,1) <= (faceBB_enlarge(1)+faceBB_enlarge(3)) & ...
                         temp(:,2) >= faceBB_enlarge(2) & temp(:,2) <= (faceBB_enlarge(2)+faceBB_enlarge(4)));
        imageStruct.sift_keypoints{1}(faceindex) = [];
        imageStruct.sift_descriptors{1}(faceindex,:) = [];
    end

    videoStruct(frameIdx) = imageStruct;
    
    if strcmp(show,'face') || strcmp(show,'all')
        imgshow = cv.drawKeypoints(imageStruct.frames,imageStruct.sift_keypoints{1});
        imshow(imgshow)
        pause(0.3)
    end

end



%% eliminate the uninteresting keypoints because of the failure of skin detection
threshold_near = 45;
% % twoclusters_index indicating which sign involves two hands
% twoclusters_index = [2,5,6,8,9];
twoclusters_index = [NaN];

% if video_num == 1
%     threshold_near = 60;
% end

[ newVideoStructCell ] = findDenseClusters_ver2( videoStruct, threshold_near, twoclusters_index, video_num, show );

% transform the new structuure cell to the old one
[ imgwithsift_structs ] = FromNewStruct2OldCell( newVideoStructCell );

end

