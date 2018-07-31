function [ output_args ] = EliminateKeypointInFaceBB( videoStruct )
% Eliminates keypoints in the face bounding boxes
% this function is developed for version after nov.2016

for frameIdx = 1:1:numFrames

    enlarge_ratio = 0.15;
    imageStruct = videoStruct(frameIdx);


    faceBB = imageStruct.faceBB;
    faceBBlarge = BoxResize(faceBB,enlarge_ratio+1);

    temp = cell2mat({imageStruct.sift_keypoints{1}.pt}');
    if ~isempty(temp) % it is possible that there is no interesting keypoints in a frame
        faceindex = find(temp(:,1) >= faceBBlarge(1) & temp(:,1) <= (faceBBlarge(1)+faceBBlarge(3)) & ...
                         temp(:,2) >= faceBBlarge(2) & temp(:,2) <= (faceBBlarge(2)+faceBBlarge(4)));
        imageStruct.sift_keypoints{1}(faceindex) = [];
        imageStruct.sift_descriptors{1}(faceindex,:) = [];
    end

    if strcmp(show,'face') || strcmp(show,'all')
        imgshow = cv.drawKeypoints(imageStruct.frames,imageStruct.sift_keypoints{1});
        imshow(imgshow)
        pause(0.3)
    end

end

end

