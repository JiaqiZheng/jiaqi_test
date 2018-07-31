%% test sift keypoints matching between the standard ASL and the frames of video recording
clear; close all;
cd /Users/qianlifeng/Documents/MATLAB
addpath('/Users/qianlifeng/Documents/MATLAB/mexopencv-2.4.11')
addpath(genpath('/Users/qianlifeng/Documents/MATLAB/codes'))


%% read the frames from imitation video
% read the original video frames
folderpath = '/Users/qianlifeng/Academic/automatic ASL imitation evaluator/imitationvideo';
v = VideoReader([folderpath,'/Qianli_newbackground3__H_S_3_imitation.avi']);
k = 1;
while hasFrame(v)
    img_temp = readFrame(v);
    video_color(:,:,:,k) = img_temp;
    video_gray(:,:,k) = rgb2gray(img_temp);
    k = k + 1;
end
[a,b,c,d] = size(video_color);
frames = ones(a,b,d);


%% read the frames from ASL videos 
% change the 'signname' if you would like to change to another sign (or subject)
% change the 'imageindex' if you would like to change the range of the
% frames in the 'signname' folder. If only one frame is needed, simply
% change the 'imageindex' to the # of that image.
signname = '01_H_S_3';
imageindex = 49:1:121;

k = 1;
for i = imageindex
    img_temp = imread(['/Users/qianlifeng/Documents/MATLAB/final chose/',signname,'/raw_',num2str(i),'.jpg']);
    ASL_color(:,:,:,k) = img_temp;
    ASL_gray(:,:,k) = rgb2gray(img_temp);
    k = k + 1;
end


%% calculate the sift keypoints and descriptors of all the frames in the video
sift_structs_imitat = cell(1,d);
descriptors_imitat = cell(1,d);
extractor = cv.DescriptorExtractor('SIFT');

for i = 1:1:d
    frame_gray = video_gray(:,:,i); % change video_gray to frontFrame if using background substraction
    sift_structs_imitat{i} = cv.SIFT(frame_gray);
    siftwithvideo = cv.drawKeypoints(frame_gray,sift_structs_imitat{i});
    imshow(siftwithvideo);
    descriptors_imitat{i} = extractor.compute(frame_gray,sift_structs_imitat{i});
    pause(0.1);
end
% sift_video = sift_structs_imitat{20};
% videoframe = video_gray(:,:,20); % change video_gray to frontFrame if using background substraction
% siftandvideo = cv.drawKeypoints(videoframe,sift_video);
% imshow(siftandvideo);

%% calculate the sift keypoints of one selected frame in the standard ASL videos
[asl_a, asl_b, asl_c, asl_d] = size(ASL_color);
sift_structs_origin = cell(1,asl_d);
descriptors_origin = cell(1,asl_d);
for i = 1:1:asl_d
    image = ASL_gray(:,:,i);
    sift_structs_origin{i} = cv.SIFT(image);
    siftwithimage = cv.drawKeypoints(image,sift_structs_origin{i});
    figure(3);
    imshow(siftwithimage);
    descriptors_origin{i} = extractor.compute(image,sift_structs_origin{i});
    pause(0.1)
end

%% eliminate outliers and still keypoints
matcher = cv.DescriptorMatcher('BruteForce');
imgwithsift_structs = cell(2,d);

outlier_thresh = 1000;  % if the distance(Euclidean squared) of the two matching keypoints is 
stiller_thresh = 25;

for i = 1:1:d-1
    frame_num1 = i;
    frame_num2 = i+1;
    imgwithsift = extractInterestingKeypoints...
                    (video_gray, sift_structs_imitat, descriptors_imitat, matcher, frame_num1, frame_num2, outlier_thresh, stiller_thresh);
    imgwithsift_structs{2,i} = imgwithsift(1);
    imgwithsift_structs{1,i+1} = imgwithsift(2);
end

%% eliminate keypoints on faces
for frame_num = 1:1:d

    imgfeature1 = imgwithsift_structs{1,frame_num};
    imgfeature2 = imgwithsift_structs{2,frame_num};

    if ~isempty(imgfeature2)
        boxes = facedetector(imgfeature2.image,false);
        rectangle = cell2mat(boxes);
        temp = cell2mat({imgfeature2.sift_keypoints.pt}');
        faceindex = find(temp(:,1) >= rectangle(1) & temp(:,1) <= (rectangle(1)+rectangle(3)) & ...
                         temp(:,2) >= rectangle(2) & temp(:,2) <= (rectangle(2)+rectangle(4)));
        imgfeature2.sift_keypoints(faceindex) = [];
        imgfeature2.sift_descriptors(faceindex) = [];

        imgshow = cv.drawKeypoints(imgfeature2.image,imgfeature2.sift_keypoints);
        imshow(imgshow)
    end
    pause(0.1)
    % do the same elimination for the first row of the imgwithsift_structs
    if ~isempty(imgfeature1)
        boxes = facedetector(imgfeature1.image,false);
        rectangle = cell2mat(boxes);
        temp = cell2mat({imgfeature1.sift_keypoints.pt}');
        faceindex = find(temp(:,1) >= rectangle(1) & temp(:,1) <= (rectangle(1)+rectangle(3)) & ...
                         temp(:,2) >= rectangle(2) & temp(:,2) <= (rectangle(2)+rectangle(4)));
        imgfeature1.sift_keypoints(faceindex) = [];
        imgfeature1.sift_descriptors(faceindex) = [];

        imgshow = cv.drawKeypoints(imgfeature1.image,imgfeature1.sift_keypoints);
        imshow(imgshow)
    end
    imgwithsift_structs{1,frame_num} = imgfeature1;
    imgwithsift_structs{2,frame_num} = imgfeature2;
    pause(0.1)
end

%% eliminate the keypoints out of skin
% get the Gaussian Mixture Model
[ ~, GMM_nonskin ] = getGMM();
load('/Users/qianlifeng/Documents/MATLAB/codes/sift_matching/GMMskin5.mat');
GMM_skin = GMM_skin_struct{4};
threshold = 0.8;
show = true;

[ video_bw ] = SkinDetectorGMM( video_color, GMM_skin, GMM_nonskin, threshold, show );

% filter out the keypoints out of the skin range
n = 1;

for frame_num = 1:1:d

    imgfeature1 = imgwithsift_structs{1,frame_num};
    imgfeature2 = imgwithsift_structs{2,frame_num};
    
    % find the 8 neighbors of the rounded keypoints pixel, check if there
    % are over half of the neighbors in the skin area
    if ~isempty(imgfeature2)
        image_bw = video_bw(:,:,frame_num);
        temp = cell2mat({imgfeature2.sift_keypoints.pt}');
        neighbor_kp = false(2*n+1,2*n+1,size(temp,1));
        k = 1;
        clear nonskinindex
        
        for i = 1:1:size(temp,1)
            seed = round(temp(i,:));
            neighbor_kp = image_bw(seed(2)-n:1:seed(2)+n,seed(1)-n:1:seed(1)+n);
            if sum(sum(neighbor_kp)) <= (2*n+1)^2/2
                nonskinindex(k) = i;
                k = k+1;
            end
        end
        
        % check if the nonskinindex exists, if not, it means that all
        % pixels are in the skin area.
        if exist('nonskinindex','var')
            imgfeature2.sift_keypoints(nonskinindex) = [];
            imgfeature2.sift_descriptors(nonskinindex) = [];
        end
        
        imgshow = cv.drawKeypoints(imgfeature2.image,imgfeature2.sift_keypoints);
        imshow(imgshow)
    end
    pause(0.1)
    
    % do the same elimination for the first row of the imgwithsift_structs
    if ~isempty(imgfeature1)
        image_bw = video_bw(:,:,frame_num);
        temp = cell2mat({imgfeature1.sift_keypoints.pt}');
        neighbor_kp = false(2*n+1,2*n+1,size(temp,1));
        k = 1;
        clear nonskinindex
        
        for i = 1:1:size(temp,1)
            seed = round(temp(i,:));
            neighbor_kp = image_bw(seed(2)-n:1:seed(2)+n,seed(1)-n:1:seed(1)+n);
            if sum(sum(neighbor_kp)) <= (2*n+1)^2/2
                nonskinindex(k) = i;
                k = k+1;
            end
        end
        
        % check if the nonskinindex exists, if not, it means that all
        % pixels are in the skin area.
        if exist('nonskinindex','var')
            imgfeature1.sift_keypoints(nonskinindex) = [];
            imgfeature1.sift_descriptors(nonskinindex) = [];
        end
        imgshow = cv.drawKeypoints(imgfeature1.image,imgfeature1.sift_keypoints);
        imshow(imgshow)
    end
    imgwithsift_structs{1,frame_num} = imgfeature1;
    imgwithsift_structs{2,frame_num} = imgfeature2;
    pause(0.1)
end




