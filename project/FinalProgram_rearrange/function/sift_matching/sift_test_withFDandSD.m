%% test sift keypoints matching between the standard ASL and the frames of video recording
% this testing is with face detector and skin detector
% Qianli Feng, Sep 17th, 2015

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

%% skin detection
for i = 1:1:size(video_color,4)
    data = video_color(:,:,:,i);
    diff_im = imsubtract(data(:,:,1), rgb2gray(data));
    imagesc(diff_im); colormap gray;
    diff_im = medfilt2(diff_im, [3 3]);
    imagesc(diff_im); colormap gray;

    diff_im = imadjust(diff_im);
    imagesc(diff_im); colormap gray;

    level = graythresh(diff_im);
    bw = im2bw(diff_im, level);
    BW5 = imfill(bw, 'holes');
    bw6 = bwlabel(BW5, 8);
    stats = regionprops(bw6, 'basic');

    bw_mat = repmat(bw6,1,1,3);
    test_image = rgb2gray(data);
    test_image =  double(test_image).*bw6;
    imagesc(test_image); colormap gray;
    pause(0.1)
    
end
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


%% calculate the sift keypoints of all the frames in the video
sift_structs_imitat = cell(1,d);

for i = 1:1:d
    frame_gray = video_gray(:,:,i); % change video_gray to frontFrame if using background substraction
    sift_structs_imitat{i} = cv.SIFT(frame_gray);
    siftwithvideo = cv.drawKeypoints(frame_gray,sift_structs_imitat{i});
    imshow(siftwithvideo);
    pause(0.1);
end
% sift_video = sift_structs_imitat{20};
% videoframe = video_gray(:,:,20); % change video_gray to frontFrame if using background substraction
% siftandvideo = cv.drawKeypoints(videoframe,sift_video);
% imshow(siftandvideo);


%% calculate the sift keypoints of one selected frame in the standard ASL videos
[asl_a, asl_b, asl_c, asl_d] = size(ASL_color);
sift_structs_origin = cell(1,asl_d);

for i = 1:1:asl_d
    image = ASL_gray(:,:,i);
    sift_structs_origin{i} = cv.SIFT(image);
    siftwithimage = cv.drawKeypoints(image,sift_structs_origin{i});
    figure(3);
    imshow(siftwithimage);
    pause(0.1)
end

%% calculate the descriptor
num_origin = 47;
num_imitat = 21;

frame_origin = ASL_gray(:,:,num_origin);
frame_imitat = video_gray(:,:,num_imitat);
sift_frame_origin = sift_structs_origin{num_origin};
sift_frame_imitat = sift_structs_imitat{num_imitat};

extractor = cv.DescriptorExtractor('SIFT');
descriptors_origin = extractor.compute(frame_origin,sift_frame_origin);
descriptors_imitat = extractor.compute(frame_imitat,sift_frame_imitat);


%% matching the descriptor
matcher = cv.DescriptorMatcher('BruteForce');
matches = matcher.match(descriptors_origin,descriptors_imitat);

im_matches = cv.drawMatches(frame_origin, sift_frame_origin, frame_imitat, sift_frame_imitat, matches);
imshow(im_matches);



