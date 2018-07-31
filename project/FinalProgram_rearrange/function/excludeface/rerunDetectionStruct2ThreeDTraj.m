function [ XYZtransformed_struct,imgfeatureRecalculate ] = rerunDetectionStruct2ThreeDTraj( imgfeature_all,showIdx )
% Calculate the 3D trajectory of the center of the hand from the detection
% structure provided by attribute detection algorithm, e.g extractSIFT.m
% the data_cell is a cell array saving all the data matrix corresponding to
% the imgfeature_all;
% the imgfeatureRecalculate is saving the imgfeature_all with the field of
% recalculate ellipse contour(ellipsecontour_2nd) and ellipse mask(ellipsemask_2nd)

% the difference between this rerun version and the original version is the
% the input image features structure has only one row.
%% 
data_cell = cell(size(showIdx));
imgfeatureRecalculate = cell(size(showIdx));
for idx = 1:1:length(showIdx)
    subNum = showIdx(idx);
    imgfeature2 = imgfeature_all{subNum};
    sigma_v = 0.3;    % variance of dynamic system
    phi = 0.2;        % variance measurement error
    outlier_threshold = 2.5;
    mode = 'Hampel';
    show = false;
    % kalman filter, outlier reduction and interpolation
    [ imgfeature2, centroid_kalman ] = NewKalmanandInterpolation( imgfeature2, sigma_v, phi, outlier_threshold, mode, show );

    % recalculate the ellipse
    [ imgfeature2 ] = rerunEllipseRecalculate( imgfeature2, centroid_kalman, show );

    %% calculate the data matrix
    % apply the re-calculated ellipse on the images and eliminate the
    % keypoints outside the mask; calculate the number of keypoints remain
%     [ sift_mat ] = DectionStruct2DataMatrix( imgfeature2, show );
    imgfeatureRecalculate{idx} = imgfeature2;
%     data_cell{subNum} = sift_mat;
end

%% SFM
% [XYZtransformed_struct,dissimilarity] = MannualLandmarksSfMtest(data_cell,30,'first',true);
XYZtransformed_struct = cell(1); 
end

