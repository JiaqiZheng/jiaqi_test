function [ imgfeature ] = EliminateKeypointsOutMask_ver2( imgfeature, image_bw, show )
%Eliminate the keypoints that not on the mask
% input:
%   1. imgfeature is the structure contains the field called sift_keypoints,
%   which contains field .pt saving the loation of all the keypoints
%   2. image_bw is the binary mask of the image, the program will save the
%   keypoints whose poistion is inside the "on" area of the image_bw
%   3. show is a string indicating whether the plot should be shown
% output:
%   1. imgfeature eliminated structure whose sift_keypoints and sift_descriptors which are in the
%   off area in image_bw are deleted.
% Qianli Feng, 2015, Nov 20

% version two changes the input to the videoStruct

% exclude the keypoints out of the skin range
n = 2;

% find the 8 neighbors of the rounded keypoints pixel, check if there
    % are over half of the neighbors in the skin area

temp = cell2mat({imgfeature.sift_keypoints{1}.pt}');
neighbor_kp = false(2*n+1,2*n+1,size(temp,1));
k = 1;
clear nonskinindex
for i = 1:1:size(temp,1)
    seed = round(temp(i,:));
    if seed(1) > 2 && seed(1) < (640 - n) && seed(2) > 2 && seed(2) < (480 - n)
        neighbor_kp = image_bw(seed(2)-n:1:seed(2)+n,seed(1)-n:1:seed(1)+n);
        if sum(sum(neighbor_kp)) <= (2*n+1)^2/2
            nonskinindex(k) = i;
            k = k+1;
        end
    else
        nonskinindex(k) = i;
        k = k+1;
    end
end

% check if the nonskinindex exists, if not, it means that all
% keypoints are in the skin area.
if exist('nonskinindex','var')
    imgfeature.sift_keypoints{1}(nonskinindex) = [];
    imgfeature.sift_descriptors{1}(nonskinindex,:) = [];
end

if strcmp(show,'skin') || strcmp(show,'all')
    imgshow = cv.drawKeypoints(bsxfun(@times,imgfeature.frames,uint8(imgfeature.skinmask)),imgfeature.sift_keypoints{1});
    imshow(imgshow)
    pause(0.3)
end


end

