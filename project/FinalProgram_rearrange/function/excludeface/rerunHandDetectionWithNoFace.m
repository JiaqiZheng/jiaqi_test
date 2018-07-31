function [ NewImgfeaturesStructur5NoFace ] = rerunHandDetectionWithNoFace( NewImgfeaturesStructur5NoFace )
% after the skin mask with no face, try to find the ellipse around the hand
% again

for VideoNum = 1:1:length(NewImgfeaturesStructur5NoFace)
    SignFeature1 = NewImgfeaturesStructur5NoFace{VideoNum};
    %% exclude the keypoints that not on the skin using the second skin mask with no face on it
    for FrameNum = 1:1:length(SignFeature1)
        imgfeature1 = SignFeature1{FrameNum};
        % overlap the remaining siftkeypoints with the ones after extract
        imgfeature1.sift_descriptors = imgfeature1.sift_descriptors_move;
        imgfeature1.sift_keypoints = imgfeature1.sift_keypoints_move;
        % find the 8 neighbors of the rounded keypoints pixel, check if there
        % are over half of the neighbors in the skin area
        if ~isempty(imgfeature1)
            image_bw = imgfeature1.SkinMaskNoFace;
            [ imgfeature1 ] = EliminateKeypointsOutMask( imgfeature1, image_bw, 'non' );
        end
        SignFeature1{FrameNum} = imgfeature1;

    end
    NewImgfeaturesStructur5NoFace{VideoNum} = SignFeature1;
    % show the remaining sift keypoints

%     for FrameNum = 1:1:length(SignFeature1)
%         imgfeature1 = SignFeature1{FrameNum};
%         imgshow = cv.drawKeypoints(imgfeature1.image,imgfeature1.sift_keypoints);
%         imshow(imgshow)
%         pause(1)
%     end
end
%% find the dense cluster of sift keypoints and label it as a hand
for VideoNum = 1:1:length(NewImgfeaturesStructur5NoFace);
    SignFeature1 = NewImgfeaturesStructur5NoFace{VideoNum};

    imgfeature1 = SignFeature1{1};
    facesize = imgfeature1.facebox{1}(3);
    threshold_near = facesize/2;
    % % twoclusters_index indicating which sign involves two hands
    % twoclusters_index = [2,5,6,8,9];
    twoclusters_index = [NaN];

    % if video_num == 1
    %     threshold_near = 60;
    % end

    [ imgwithsift_structs ] = rerunFindDenseClusters( SignFeature1, threshold_near, twoclusters_index, VideoNum, 'non' );
    NewImgfeaturesStructur5NoFace{VideoNum} = imgwithsift_structs;
end

%% rerun the kalman filter and sign detection
showIdx = 1:1:length(NewImgfeaturesStructur5NoFace);
[ XYZtransformed_struct,NewImgfeaturesStructur5NoFace ] = rerunDetectionStruct2ThreeDTraj( NewImgfeaturesStructur5NoFace,showIdx );

% %% visualize the result
% pauseTime = [0.2,1];
% mode1 = 'ImageWith2ndEllipseContour';
% showMasks( NewImgfeaturesStructur5NoFace,mode1,pauseTime )

end

