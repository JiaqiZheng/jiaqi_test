function [ imgwithsift_structs ] = FromNewStruct2OldCell( newVideoStructCell )
% transform the newVideoStructCell to old imgwithsift_structs cell
imgwithsift_structs = cell(1,length(newVideoStructCell));
for frameIdx = 1:1:length(newVideoStructCell)
    thisStruct = newVideoStructCell{frameIdx};
    newStruct = thisStruct;
    newStruct = rmfield(newStruct,{'frames','faceBB','sift_keypoints','sift_descriptors','sift_keypoints_full','sift_descriptors_full','sift_keypoints_move','sift_descriptors_move'});
    newStruct.image = thisStruct.frames;
    
    newStruct.sift_keypoints = thisStruct.sift_keypoints{1};
    newStruct.sift_descriptors = thisStruct.sift_descriptors{1};
    
    newStruct.sift_keypoints_full = thisStruct.sift_keypoints_full{1};
    newStruct.sift_descriptors_full = thisStruct.sift_descriptors_full{1};
    
    newStruct.sift_keypoints_move = thisStruct.sift_keypoints_move{1};
    newStruct.sift_descriptors_move = thisStruct.sift_descriptors_move{1};
    
    newStruct.facebox{1} = thisStruct.faceBB;
    imgwithsift_structs{frameIdx} = newStruct;
end

end

