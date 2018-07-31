%% 
imgwithsift_structs_imitat = RuiqiSiftResults_struct_test2{10};
for frame_num = 1:1:length(imgwithsift_structs_imitat)-1

    imgfeature2 = imgwithsift_structs_imitat{2,frame_num};
    threshold_near = 35;
%     imgshow = cv.drawKeypoints(imgfeature1.image,imgfeature1.sift_keypoints);
%     imshow(imgshow)
    keypoint_coord = cell2mat({imgfeature2.sift_keypoints.pt}');
    distance = pdist(keypoint_coord,'euclidean');
    distance_mat = squareform(distance);
    
    nearpoints = false(size(distance_mat));
    nearpoints(distance_mat <= threshold_near) = true;
    neighbour_nums = sum(double(nearpoints));
    center1 = find(neighbour_nums >= max(neighbour_nums));
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
    elseif hand_num == 1
        neighbour_index = neighbour1_index;
    end
        
    imgshow = cv.drawKeypoints(imgfeature2.image,imgfeature2.sift_keypoints(neighbour_index));
    imshow(imgshow)
    pause(0.1)
end
