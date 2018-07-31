function [ newVideoStructCell ] = findDenseClusters_ver2( videoStruct, threshold_near, twoclusters_index, video_num, show )
%Find the the cluster with highest point density and the another highly
%dense cluster but away from the first one.
%   Detailed explanation goes here
% Feng, Qianli, Oct 7, 2015

if find(twoclusters_index == video_num)
    hand_num = 2;
else
    hand_num = 1;
end

for frameIdx = 1:1:length(videoStruct)
    imagefeature = videoStruct(frameIdx);

    if ~isempty(imagefeature) && length(imagefeature.sift_keypoints{1}) > 1
    %     imgshow = cv.drawKeypoints(imgfeature1.frames,imgfeature1.sift_keypoints);
    %     imshow(imgshow)
        keypoint_coord = cell2mat({imagefeature.sift_keypoints{1}.pt}');
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
            imagefeature.neighbour{1} = neighbour1_index;
            imagefeature.neighbour{2} = neighbour2_index;
        elseif hand_num == 1
            neighbour_index = neighbour1_index;
            imagefeature.neighbour{1} = neighbour1_index;
        end

        % calculate the convex hull
        imagefeature = siftmask_ver2(imagefeature);
%         imgfeature2.sift_keypoints = imgfeature2.sift_keypoints(neighbour_index);
%         imgfeature2.sift_descriptors = imgfeature2.sift_descriptors(neighbour_index);

        if strcmp(show,'dense') || strcmp(show,'all')
            imgshow = cv.drawKeypoints(imagefeature.frames,imagefeature.sift_keypoints{1}(neighbour_index));
            imshow(imgshow)
            pause(0.3);
        end
        
    end
    
    newVideoStructCell{frameIdx} = imagefeature;

end


end

