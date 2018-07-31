%% test sift keypoints matching between the standard ASL and the frames of video recording
clear; close all;
cd /Users/qianlifeng/Documents/MATLAB
addpath(genpath('./mexopencv-2.4.11'))
addpath(genpath('./codes'))
addpath(genpath('./extensionpackage'))

%% read the frames from imitation video
% read the original video frames
name = 'Qianli';
version = 'newframerate';
show = 'non';
folderpath = '/Users/qianlifeng/Academic/automatic ASL imitation evaluator/imitationvideo';
videolist = dir([folderpath,'/',name,'/',version,'/*.avi']);

savename = [name,'SiftResults_struct_test3'];

eval([savename,' = cell(1,length(videolist))']);

H = waitbar(0,'Processing...');
for video_num = 1:1:length(videolist)

    clear video_color video_gray
    k = 1;
    v = VideoReader([folderpath,'/',name,'/',version,'/',videolist(video_num).name]);
    while hasFrame(v)
        img_temp = readFrame(v);
        video_color(:,:,:,k) = img_temp;
        video_gray(:,:,k) = rgb2gray(img_temp);
        k = k + 1;
    end
    [a,b,c,d] = size(video_color);
    frames = ones(a,b,d);
    
    %% calculate the sift keypoints and descriptors of all the frames in the video
    tic
    [ imgwithsift_structs_imitat ] = ExtractSIFTkeypoints( video_color, video_gray, show, video_num);
    toc
    eval([savename,'{video_num} = imgwithsift_structs_imitat']);
    
    waitbar(video_num/length(videolist),H);
   
end

%% show the final SIFT keypoints results
imgwithsift_structs_imitat = RamSiftResults_struct_test2{3};
for frame_num = 1:1:length(imgwithsift_structs_imitat)
    imgfeature1 = imgwithsift_structs_imitat{1,frame_num};
    imgfeature2 = imgwithsift_structs_imitat{2,frame_num};
    if ~isempty(imgfeature1)
        imgshow = cv.drawKeypoints(imgfeature1.image,imgfeature1.sift_keypoints);
        imshow(imgshow)
%         imshow(imgfeature1.skinmask)
    end
    
    pause(1)
end


%% read the frames from ASL videos and extract SIFT features 
% change the 'signname' if you would like to change to another sign (or subject)
% change the 'imageindex' if you would like to change the range of the
% frames in the 'signname' folder. If only one frame is needed, simply
% change the 'imageindex' to the # of that image.
name = 'Origin';
show = 'non';
originfolderpath = '/Users/qianlifeng/Academic/automatic ASL imitation evaluator/original sign';
originsign = dir(originfolderpath);
originsign(1:3) = [];

H = waitbar(0,'Processing...');
for sign_num = 1:1:length(originsign)
    signname = originsign(sign_num).name;
    imagelist = dir([originfolderpath,'/',signname,'/*.jpg']);
    [imagelist,~] = sort_nat({imagelist.name});
    clear ASL_color ASL_gray

    for i = 1:1:length(imagelist)
        img_temp = imread([originfolderpath,'/',signname,'/',imagelist{i}]);
        ASL_color(:,:,:,i) = img_temp;
        ASL_gray(:,:,i) = rgb2gray(img_temp);
    end
    
    [ imgwithsift_origin ] = ExtractSIFTkeypoints( ASL_color, ASL_gray, show, sign_num);
    % for the double frame repitation, duplicate the original sift.
%     imgwithsift_structs_origin = cell(size(imgwithsift_origin,1),2*size(imgwithsift_origin,2));
%     i = 1:2:2*length(imgwithsift_origin)-1;
%     imgwithsift_structs_origin(:,i) = imgwithsift_origin;
%     j = i+1;
%     imgwithsift_structs_origin(:,j) = imgwithsift_origin;
    eval([name,'SiftResults_struct{sign_num} = imgwithsift_origin']);
    waitbar(sign_num/length(originsign),H);
    
end

%% show the final SIFT keypoints results
imgwithsift_structs_imitat = OriginSiftResults_struct{2};
for frame_num = 1:1:length(imgwithsift_structs_imitat)
    imgfeature1 = imgwithsift_structs_imitat{1,frame_num};
    imgfeature2 = imgwithsift_structs_imitat{2,frame_num};
    if ~isempty(imgfeature1)
        imgshow = cv.drawKeypoints(imgfeature1.image,imgfeature1.sift_keypoints);
        imshow(imgshow)
    end
end

save('fullkalmanresult.mat','QianliSiftResults_struct_test3','FabianSiftResults_struct_test3','RuiqiSiftResults_struct_test3','OriginSiftResults_struct','-v7.3')

