%% test sift keypoints matching between the standard ASL and the frames of video recording
clear; close all;
cd /Users/qianlifeng/Documents/MATLAB
addpath('/Users/qianlifeng/Documents/MATLAB/mexopencv-2.4.11')
addpath(genpath('/Users/qianlifeng/Documents/MATLAB/codes'))


%% read the frames from imitation video
% read the original video frames
folderpath = '/Users/qianlifeng/Academic/automatic ASL imitation evaluator/imitationvideo';
v = VideoReader([folderpath,'/test_newbackground__H_S_3_imitation.avi']);
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


%% Background Substraction
% if need background substraction, uncomment this section. The varThreshold
% can be tweaked for different substraction results.

BS = cv.BackgroundSubtractorMOG2();
BS.varThreshold = 150;
frontMask_mat = zeros(a,b,d,'uint8');
for i = 1:1:d
    frame_color = video_color(:,:,:,i);
    frontMask = BS.apply(frame_color);
%     CC = bwconncomp(frontMask);
%     imagesc(CC,[0,1]);
    frontMask_mat(:,:,i) = frontMask;
    pause(0.1)
end

% show the substracted images
frontFrame = video_gray .* frontMask_mat;
for j = 1:1:d
    img_temp = frontFrame(:,:,j);
    imagesc(img_temp);
    colormap gray;
    pause(0.1);
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


%% find the keypoints that move significantly acorss the frames
% for frame_num = 1:size(sift_structs_origin,2);
%     posKeypoints_origin = {sift_structs_origin{frame_num}.pt};
%     posKeypoints_origin2 = zeros(size(posKeypoints_origin,2),2);
%     for i = 1:1:size(posKeypoints_origin,2)
%         posKeypoints_origin2(i,1) = posKeypoints_origin{i}(1);
%         posKeypoints_origin2(i,2) = posKeypoints_origin{i}(2);
%     end
%     histogram(posKeypoints_origin2(:,1),50);
%     pause(1);
% end


%% calculate the descriptor
num_origin = 47;
num_origin2 = 48;

num_imitat = 47;
num_imitat2 = 48;

frame_origin = ASL_gray(:,:,num_origin);
sift_frame_origin = sift_structs_origin{num_origin};

frame_origin2 = ASL_gray(:,:,num_origin2);
sift_frame_origin2 = sift_structs_origin{num_origin2};

frame_imitat = video_gray(:,:,num_imitat);
sift_frame_imitat = sift_structs_imitat{num_imitat};

frame_imitat2 = video_gray(:,:,num_imitat2);
sift_frame_imitat2 = sift_structs_imitat{num_imitat2};

extractor = cv.DescriptorExtractor('SIFT');
descriptors_origin = extractor.compute(frame_origin,sift_frame_origin);
descriptors_origin2 = extractor.compute(frame_origin2,sift_frame_origin2);

descriptors_imitat = extractor.compute(frame_imitat,sift_frame_imitat);
descriptors_imitat2 = extractor.compute(frame_imitat2,sift_frame_imitat2);


%% matching the descriptor
matcher = cv.DescriptorMatcher('BruteForce');
matches = matcher.match(descriptors_origin,descriptors_origin2);
matches2 = matcher.match(descriptors_imitat,descriptors_imitat2);

im_matches_oringi = cv.drawMatches(frame_origin, sift_frame_origin, frame_origin2, sift_frame_origin2, matches);
imshow(im_matches_oringi);

figure;
im_matches_imitat = cv.drawMatches(frame_imitat, sift_frame_imitat, frame_imitat2, sift_frame_imitat2, matches2);
imshow(im_matches_imitat);

%% extract the matching points
% the standard video
match_points = [matches.queryIdx;matches.trainIdx]'; % the queryIdx corresponding to the first input argument in matcher.match(); the trainIdx corresponding to the second
match_points_querycoord = cell2mat({sift_frame_origin(match_points(:,1)+1).pt}'); % actually indexing the sift_frame_origin here is not necessary, since the query index is naturally ordered
match_points_traincoord = cell2mat({sift_frame_origin2(match_points(:,2)+1).pt}');

match_points_distance = match_points_querycoord - match_points_traincoord;
match_points_distance(:,3) = match_points_distance(:,1).^2 + match_points_distance(:,2).^2;

outlier_thresh = 1000;  % if the distance(Euclidean squared) of the two matching keypoints is 
stiller_thresh = 20;

matches_onlymove = matches(match_points_distance(:,3) <= outlier_thresh & match_points_distance(:,3) >= stiller_thresh);

% --- test the result of excluding outliers------ %
im_matches_oringi = cv.drawMatches(frame_origin, sift_frame_origin, frame_origin2, sift_frame_origin2, matches_onlymove);
imshow(im_matches_oringi);
% ----------------------------------------------- %

% the imitation video
match_points = [matches2.queryIdx;matches2.trainIdx]' + 1; % the queryIdx corresponding to the first input argument in matcher.match(); the trainIdx corresponding to the second
match_points_imitat = cell2mat({sift_frame_imitat(match_points(:,1)).pt}'); % actually indexing the sift_frame_origin here is not necessary, since the query index is naturally ordered
match_points_imitat2 = cell2mat({sift_frame_imitat2(match_points(:,2)).pt}');

outlier_thresh = 1000;  % if the distance(Euclidean squared) of the two matching keypoints is 
stiller_thresh = 20;

[ matches_index_onlymove, match_points_index_onlymove ] = extractMatchingKeypoints...
    ( match_points, match_points_imitat, match_points_imitat2, outlier_thresh, stiller_thresh );

matches_onlymove = matches2(matches_index_onlymove);

% --- test the result of excluding outliers------ %
im_matches_imitat = cv.drawMatches(frame_imitat, sift_frame_imitat, frame_imitat2, sift_frame_imitat2, matches_onlymove);
imshow(im_matches_imitat);


sift_frame_imitat_onlymove = sift_frame_imitat(match_points_index_onlymove(:,1));
sift_frame_imitat2_onlymove = sift_frame_imitat2(match_points_index_onlymove(:,2));

siftwithimage_imitat_onlymove = cv.drawKeypoints(frame_imitat,sift_frame_imitat_onlymove);
imshow(siftwithimage_imitat_onlymove)

siftwithimage_imitat2_onlymove = cv.drawKeypoints(frame_imitat2,sift_frame_imitat2_onlymove);
figure;
imshow(siftwithimage_imitat2_onlymove);


