function [ XYZtransformed_struct,imgfeatureRecalculate ] = DetectionStruct2ThreeDTraj( imgfeature_all,showIdx )
% Calculate the 3D trajectory of the center of the hand from the detection
% structure provided by attribute detection algorithm, e.g extractSIFT.m
% the data_cell is a cell array saving all the data matrix corresponding to
% the imgfeature_all;
% the imgfeatureRecalculate is saving the imgfeature_all with the field of
% recalculate ellipse contour(ellipsecontour_2nd) and ellipse mask(ellipsemask_2nd)
%% 
data_cell = cell(size(showIdx));
imgfeatureRecalculate = cell(size(showIdx));
for idx = 1:1:length(showIdx)
    subNum = showIdx(idx);
    imgfeature2 = imgfeature_all{subNum}(2,1:end-2);
    sigma_v = 0.3;    % variance of dynamic system
    phi = 0.2;        % variance measurement error
    outlier_threshold = 2.5;
    mode = 'IterativeGaussian';
    show = true;
    % kalman filter, outlier reduction and interpolation
    try
        [ imgfeature2, centroid_kalman ] = KalmanandInterpolation( imgfeature2, sigma_v, phi, outlier_threshold, mode, show );
        % recalculate the ellipse
        [ imgfeature2 ] = EllipseRecalculate( imgfeature2, centroid_kalman, show );
    catch ME
        if strcmp(ME.identifier, 'MATLAB:subsassigndimmismatch') && strcmp(ME.stack(1).name,'ExcludeHTOutliersInterpolation')
            disp(['No sufficient number of SIFT keypoints remaining for all frames in video ',num2str(idx)]);
            imgfeature2 = [];
        end
    end
    

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

