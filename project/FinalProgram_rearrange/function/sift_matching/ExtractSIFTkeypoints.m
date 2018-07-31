function [ imgwithsift_structs ] = ExtractSIFTkeypoints( video_color, video_gray, show, video_num)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

%% test sift keypoints matching between the standard ASL and the frames of video recording
[a,b,c,d] = size(video_color);

%% calculate the sift keypoints and descriptors of all the frames in the video
sift_structs = cell(1,d);
descriptors = cell(1,d);
extractor = cv.DescriptorExtractor('SIFT');

for i = 1:1:d
    frame_gray = video_gray(:,:,i); % change video_gray to frontFrame if using background substraction
    sift_structs{i} = cv.SIFT(frame_gray);
    descriptors{i} = extractor.compute(frame_gray,sift_structs{i});
    
    frame_color = video_color(:,:,:,i);
    if strcmp(show,'originSIFT') || strcmp(show,'all')
        siftwithvideo = cv.drawKeypoints(frame_color,sift_structs{i});
        imshow(siftwithvideo);
        pause(0.3);
    end
end
% sift_video = sift_structs_imitat{20};
% videoframe = video_gray(:,:,20); % change video_gray to frontFrame if using background substraction
% siftandvideo = cv.drawKeypoints(videoframe,sift_video);
% imshow(siftandvideo);

%% eliminate outliers and still keypoints
matcher = cv.DescriptorMatcher('BruteForce');
imgwithsift_structs = cell(2,d);

outlier_thresh = inf;  % if the distance(Euclidean squared) of the two matching keypoints is 
stiller_thresh = 2;



for i = 1:1:d-1
    frame_num1 = i;
    frame_num2 = i+1;
    imgwithsift = extractInterestingKeypoints...
                    (video_color, sift_structs, descriptors, matcher, frame_num1, frame_num2, outlier_thresh, stiller_thresh, show);
    imgwithsift_structs{2,i} = imgwithsift(1);
    imgwithsift_structs{1,i+1} = imgwithsift(2);
end

%% eliminate keypoints on faces
for frame_num = 1:1:d

    enlarge_ratio = 0.15;
    
    imgfeature1 = imgwithsift_structs{1,frame_num};
    imgfeature2 = imgwithsift_structs{2,frame_num};

    if ~isempty(imgfeature2)
        boxes = facedetector(imgfeature2.image,false);
        
        if ~isempty(boxes)
            rectangle = cell2mat(boxes);
        elseif isempty(boxes) && frame_num == 1
            tempFrameNum = frame_num;
            while isempty(boxes)
                tempFrameNum = tempFrameNum + 1;
                imgfeature2 = imgwithsift_structs{2,tempFrameNum};
                boxes = facedetector(imgfeature2.image,false);
            end
            rectangle = cell2mat(boxes);
        end
        enlarge_num = round(enlarge_ratio*rectangle(3)); % rectangle(3) is the width or height of the squared face bounding box
        rectangle_enlarge = [rectangle(1)-enlarge_num/2, rectangle(2)-enlarge_num/2, ...
                             rectangle(3)+enlarge_num, rectangle(4)+enlarge_num];
        imgfeature2.facebox{:} = rectangle_enlarge(1:4);
        
        temp = cell2mat({imgfeature2.sift_keypoints.pt}');
        if ~isempty(temp) % it is possible that there is no interesting keypoints in a frame
            faceindex = find(temp(:,1) >= rectangle_enlarge(1) & temp(:,1) <= (rectangle_enlarge(1)+rectangle_enlarge(3)) & ...
                             temp(:,2) >= rectangle_enlarge(2) & temp(:,2) <= (rectangle_enlarge(2)+rectangle_enlarge(4)));
            imgfeature2.sift_keypoints(faceindex) = [];
            imgfeature2.sift_descriptors(faceindex,:) = [];
        end
        
        if strcmp(show,'face') || strcmp(show,'all')
            imgshow = cv.drawKeypoints(imgfeature2.image,imgfeature2.sift_keypoints);
            imshow(imgshow)
            pause(0.3)
        end
    end
    
    % do the same elimination for the first row of the imgwithsift_structs
    if ~isempty(imgfeature1)
        boxes = facedetector(imgfeature1.image,false);
        if ~isempty(boxes)
            rectangle = cell2mat(boxes);
        elseif isempty(boxes) && frame_num == 1
            while isempty(boxes)
                tempFrameNum = frame_num;
                tempFrameNum = tempFrameNum + 1;
                imgfeature2 = imgwithsift_structs{2,tempFrameNum};
                boxes = facedetector(imgfeature2.image,false);
            end
            rectangle = cell2mat(boxes);
        end
        enlarge_num = round(enlarge_ratio*rectangle(3)); % rectangle(3) is the width or height of the squared face bounding box
        rectangle_enlarge = [rectangle(1)-enlarge_num/2, rectangle(2)-enlarge_num/2, ...
                             rectangle(3)+enlarge_num, rectangle(4)+enlarge_num];
        imgfeature1.facebox{:} = rectangle_enlarge(1:4);
        temp = cell2mat({imgfeature1.sift_keypoints.pt}');
        if ~isempty(temp)  % it is possible that there is no interesting keypoints in a frame
            faceindex = find(temp(:,1) >= rectangle_enlarge(1) & temp(:,1) <= (rectangle_enlarge(1)+rectangle_enlarge(3)) & ...
                             temp(:,2) >= rectangle_enlarge(2) & temp(:,2) <= (rectangle_enlarge(2)+rectangle_enlarge(4)));
            imgfeature1.sift_keypoints(faceindex) = [];
            imgfeature1.sift_descriptors(faceindex,:) = [];
        end
        
        if strcmp(show,'face') || strcmp(show,'all')
            imgshow = cv.drawKeypoints(imgfeature1.image,imgfeature1.sift_keypoints);
            imshow(imgshow)
            pause(0.3)
        end
    end
    imgwithsift_structs{1,frame_num} = imgfeature1;
    imgwithsift_structs{2,frame_num} = imgfeature2;
    
end

%% eliminate the keypoints out of skin
% get the Gaussian Mixture Model
% [ GMM_skin, GMM_nonskin ] = getGMM();
load('./GMMdata/GMM_13000skin6DB4.mat');
load('./GMMdata/GMM_23000nonskin4.mat');
% threshGMM = 3.2; %3.2;
% [ video_bw ] = SkinDetectorGMM( video_color, GMM_skin, GMM_nonskin, threshGMM, show );

threshold = 1.5;
weight = 0.5;
[ video_bw ] = SkinDetectorGMMFace( video_color, GMM_skin, GMM_nonskin, threshold, weight, 'all');


% [ video_bw ] = SkinDetectionGMMFD( video_color,video_gray, GMM_skin, GMM_nonskin, threshGMM, threshFD, true );

for frame_num = 1:1:d

    imgfeature1 = imgwithsift_structs{1,frame_num};
    imgfeature2 = imgwithsift_structs{2,frame_num};
    
    % find the 8 neighbors of the rounded keypoints pixel, check if there
    % are over half of the neighbors in the skin area
    if ~isempty(imgfeature2)
        image_bw = video_bw(:,:,frame_num);
        [ imgfeature2 ] = EliminateKeypointsOutMask( imgfeature2, image_bw, show );
        imgfeature2.skinmask = image_bw;
    end
%     pause(0.1)
    
    % do the same elimination for the first row of the imgwithsift_structs
    if ~isempty(imgfeature1)
        image_bw = video_bw(:,:,frame_num);
        [ imgfeature1 ] = EliminateKeypointsOutMask( imgfeature1, image_bw, show );
        imgfeature1.skinmask = image_bw;
    end
    imgwithsift_structs{1,frame_num} = imgfeature1;
    imgwithsift_structs{2,frame_num} = imgfeature2;
%     pause(0.1)
end

%% eliminate the uninteresting keypoints because of the failure of skin detection
threshold_near = 45;
% % twoclusters_index indicating which sign involves two hands
% twoclusters_index = [2,5,6,8,9];
twoclusters_index = [NaN];

% if video_num == 1
%     threshold_near = 60;
% end

[ imgwithsift_structs ] = findDenseClusters( imgwithsift_structs, threshold_near, twoclusters_index, video_num, show );


end

