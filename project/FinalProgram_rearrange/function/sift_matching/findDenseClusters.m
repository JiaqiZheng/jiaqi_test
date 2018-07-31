function [ imgwithsift_structs ] = findDenseClusters( imgwithsift_structs, threshold_near, twoclusters_index, video_num, show )
%Find the the cluster with highest point density and the another highly
%dense cluster but away from the first one.
%   Detailed explanation goes here
% Feng, Qianli, Oct 7, 2015

if find(twoclusters_index == video_num)
    hand_num = 2;
else
    hand_num = 1;
end

for frame_num = 1:1:length(imgwithsift_structs)
    imgfeature1 = imgwithsift_structs{1,frame_num};
    imgfeature2 = imgwithsift_structs{2,frame_num};

    if ~isempty(imgfeature2) && length(imgfeature2.sift_keypoints) > 1
    %     imgshow = cv.drawKeypoints(imgfeature1.image,imgfeature1.sift_keypoints);
    %     imshow(imgshow)
        keypoint_coord = cell2mat({imgfeature2.sift_keypoints.pt}');
        distance = pdist(keypoint_coord,'euclidean');
        distance_mat = squareform(distance);

        nearpoints = false(size(distance_mat));
        nearpoints(distance_mat <= threshold_near) = true;
        neighbour_nums = sum(double(nearpoints));
        center1 = find(neighbour_nums == max(neighbour_nums));
        nearpoints(:,center1);
        [neighbour1_index,~] = find(nearpoints(:,center1));
        neighbour1_index = unique(neighbour1_index);

        if hand_num == 2
            % solve the two hand problem
            loss = zeros(1,size(distance_mat,1));
            for p = 1:1:size(distance_mat,1)
                [nearindex_rows, ~] = find(nearpoints(:,p));
                sharedpoints = intersect(neighbour1_index,nearindex_rows);
                loss(p) = length(nearindex_rows) + size(distance_mat,1) - length(sharedpoints);
            end
            center2 = find(loss==max(loss));
            [neighbour2_index, ~] = find(nearpoints(:,center2));
            neighbour_index = unique([neighbour1_index;neighbour2_index]);
            imgfeature2.neighbour{1} = neighbour1_index;
            imgfeature2.neighbour{2} = neighbour2_index;
        elseif hand_num == 1
            neighbour_index = neighbour1_index;
            imgfeature2.neighbour{1} = neighbour1_index;
        end

        % calculate the convex hull
        imgfeature2 = siftmask(imgfeature2);
%         imgfeature2.sift_keypoints = imgfeature2.sift_keypoints(neighbour_index);
%         imgfeature2.sift_descriptors = imgfeature2.sift_descriptors(neighbour_index);

        if strcmp(show,'dense') || strcmp(show,'all')
            imgshow = cv.drawKeypoints(imgfeature2.image,imgfeature2.sift_keypoints(neighbour_index));
            imshow(imgshow)
            pause(0.3);
        end
        
    end
    
    if ~isempty(imgfeature1) && length(imgfeature1.sift_keypoints) > 1
    %     imgshow = cv.drawKeypoints(imgfeature1.image,imgfeature1.sift_keypoints);
    %     imshow(imgshow)
        keypoint_coord = cell2mat({imgfeature1.sift_keypoints.pt}');
        distance = pdist(keypoint_coord,'euclidean');
        distance_mat = squareform(distance);

        nearpoints = false(size(distance_mat));
        nearpoints(distance_mat <= threshold_near) = true;
        neighbour_nums = sum(double(nearpoints));
        center1 = find(neighbour_nums >= max(neighbour_nums));
        nearpoints(:,center1);
        [neighbour1_index,~] = find(nearpoints(:,center1));
        neighbour1_index = unique(neighbour1_index); % there may be multiple maximum, show them all

        if hand_num == 2
        % solve the two hand problem
            loss = zeros(1,size(distance_mat,1));
            for p = 1:1:size(distance_mat,1)
                [nearindex_rows, ~] = find(nearpoints(:,p));
                sharedpoints = intersect(neighbour1_index,nearindex_rows);
                loss(p) = length(nearindex_rows) + size(distance_mat,1) - length(sharedpoints);
            end
            center2 = find(loss==max(loss));
            [neighbour2_index, ~] = find(nearpoints(:,center2));
            neighbour_index = unique([neighbour1_index;neighbour2_index]);
            imgfeature1.neighbour{1} = neighbour1_index;
            imgfeature1.neighbour{2} = neighbour2_index;
        elseif hand_num == 1
            neighbour_index = neighbour1_index;
            imgfeature1.neighbour{1} = neighbour1_index;
        end

%         imgfeature1.sift_keypoints = imgfeature1.sift_keypoints(neighbour_index);
%         imgfeature1.sift_descriptors = imgfeature1.sift_descriptors(neighbour_index);
        
        % calculate the convex hull
        imgfeature1 = siftmask(imgfeature1);
        
%         if strcmp(show,'dense') || strcmp(show,'all')
%             imgshow = cv.drawKeypoints(imgfeature1.skinmask,imgfeature1.sift_keypoints(neighbour_index));
%             imshow(imgshow)
%             pause(0.3)
%         end
        
    end
    
    imgwithsift_structs{1,frame_num} = imgfeature1;
    imgwithsift_structs{2,frame_num} = imgfeature2;
    
end


end

