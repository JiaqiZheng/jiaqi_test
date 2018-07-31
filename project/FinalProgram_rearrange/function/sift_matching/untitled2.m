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
