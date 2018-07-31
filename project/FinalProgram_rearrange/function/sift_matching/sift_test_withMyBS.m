%% test sift keypoints matching between the standard ASL and the frames of video recording using my method of background substraction

clear; close all;
cd /Users/qianlifeng/Documents/MATLAB
addpath('/Users/qianlifeng/Documents/MATLAB/mexopencv-2.4.11')


%% read the frames from imitation video
% read the original video frames
folderpath = '/Users/qianlifeng/Academic/automatic ASL imitation evaluator/imitationvideo';
v = VideoReader([folderpath,'/new_Qianli__H_S_3_imitation.avi']);
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
% % uncomment this when you want to save the frames in the dataset to a
% % matrix. Don't forget to change the range of iteration to what you need.
% 
% k = 1;
% for i = 49:1:121
%     img_temp(k) = imread(['/Users/qianlifeng/Documents/MATLAB/final chose/01_H_S_3/raw_',num2str(i),'.jpg']);
%     k = k + 1;
% end


%% Background Substraction
% if need background substraction, uncomment this section. The varThreshold
% can be tweaked for different substraction results.

% % this is the original OpenCV background substraction
% BS = cv.BackgroundSubtractorMOG2();
% BS.varThreshold = 200;
% frontMask_mat = zeros(a,b,d,'uint8');
% for i = 1:1:d
%     frame_color = video_color(:,:,:,i);
%     frontMask = BS.apply(frame_color);
%     imagesc(frontMask,[0,1]);
%     frontMask_mat(:,:,i) = frontMask;
%     pause(0.1)
% end
% 
% % show the substracted images
% frontFrame = video_gray .* frontMask_mat;
% for j = 1:1:d
%     img_temp = frontFrame(:,:,j);
%     imagesc(img_temp);
%     colormap gray;
%     pause(0.1);
% end

% this is my version of background substraction, which require a short
% video of background
bv = VideoReader([folderpath,'/background__H_S_3_imitation.avi']);
k = 1;
while hasFrame(bv)
    bgimg_temp = readFrame(bv);
    backgroundvideo_color(:,:,:,k) = bgimg_temp;
    backgroundvideo_gray(:,:,k) = rgb2gray(bgimg_temp);
    k = k + 1;
end
[ba,bb,bc,bd] = size(backgroundvideo_color);
meanbackground_color = mean(backgroundvideo_color,4);
meanbackground_gray = mean(backgroundvideo_gray,3);

frontFrame_gray = bsxfun(@minus,double(video_gray),meanbackground_gray);
frontFrame_gray = 

img_temp2 = ones(size(img_temp));
img_temp2(img_temp < 40 & img_temp > -40) = 0;
imagesc(img_temp2,[0 1]);

for i = 1:1:bd
    img_temp = frontFrame_gray(:,:,i);
    imagesc(img_temp);
    colormap gray;
    pause(0.05)
end


%% calculate the sift keypoints of all the frames in the video
sift_structs = cell(1,d);

for i = 1:1:d
    frame_gray = frontFrame(:,:,i); % change video_gray to frontFrame if using background substraction
    sift_frame = cv.SIFT(frame_gray);
    sift_structs{i} = sift_frame;
end
sift_video = sift_structs{20};
videoframe = frontFrame(:,:,20); % change video_gray to frontFrame if using background substraction
siftandvideo = cv.drawKeypoints(videoframe,sift_video);
imshow(siftandvideo);


%% calculate the sift keypoints of one selected frame in the standard ASL
% videos
image = imread('/Users/qianlifeng/Documents/MATLAB/final chose/01_H_S_3/raw_83_hand.jpeg');
image = rgb2gray(image);

sift_image = cv.SIFT(image);
siftwithimage = cv.drawKeypoints(image,sift_image);
figure
imshow(siftwithimage);


%% calculate the descriptor
extractor = cv.DescriptorExtractor('SIFT');
descriptors_image = extractor.compute(image,sift_image);
descriptors_video = extractor.compute(videoframe,sift_video);


%% matching the descriptor
matcher = cv.DescriptorMatcher('BruteForce');
matches = matcher.match(descriptors_image,descriptors_video);

im_matches = cv.drawMatches(image, sift_image, videoframe, sift_video, matches);
imshow(im_matches);



