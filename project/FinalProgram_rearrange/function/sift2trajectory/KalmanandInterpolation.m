function [ imgfeature2, centroid_kalman ] = KalmanandInterpolation( imgfeature2, sigma_v, phi, outlier_threshold, mode, show )
%Run kalman filter, outlier reduction, and missing point interpolation 
% imgfeature2        % structure contains the previous detection result
% sigma_v            % variance of dynamic system
% phi                % variance measurement error
% outlier_threshold  % the std interval for outliers reduction

s_post = struct('result',[]);
P_post = struct('EstimationErrorCovariance',[]);


%% run kalman filter
for k2 = 1:1:length(imgfeature2)
%     if isfield(imgfeature2{k2},'centroidAvg')
%         current_cent = cell2mat(imgfeature2{k2}.centroidAvg);
%     else
%         current_cent = [];
%     end
%     [ kalmanresult, s_post, P_post ] = kalmanfilter( k2, current_cent', sigma_v, phi, s_post, P_post,[320,240], 2 );
%     centroid_kalman(k2,:) = kalmanresult';
%     imshow(imgfeature2{k2}.image);
%     hold on
%     plot(centroid_kalman(:,1),centroid_kalman(:,2),'r-');
%     plot(kalmanresult(1),kalmanresult(2),'g*');
%     
%     imgfeature2{k2}.kalmanresult = kalmanresult;
    if isfield(imgfeature2{k2},'centroidAvg')
        current_cent = cell2mat(imgfeature2{k2}.centroidAvg);
    else
        current_cent = [NaN,NaN];
    end
    numSIFTkeypoints(k2) = length(imgfeature2{k2}.sift_keypoints);
%     current_cent = imgfeature2{k2}.centroidAvg{1};
    withoutkalmanresult = current_cent;
    centroid_withoutkalman(k2,:) = withoutkalmanresult';
 
    if show
        imshow(imgfeature2{k2}.image);
        hold on
        plot(centroid_withoutkalman(:,1),centroid_withoutkalman(:,2),'r.');
        plot(withoutkalmanresult(1),withoutkalmanresult(2),'g*');
    %     plot(centroid_withoutkalman([outliers_index(2)],1),centroid_withoutkalman([outliers_index(2)],2),'g.');
    %     plot(centroid_withoutkalman(59,1),centroid_withoutkalman(59,2),'b.');


        pause(0.2) 
    end
end

%% chose only the sign frames
[ centroid_withoutkalman, imgfeature2 ] = SignFrames( numSIFTkeypoints, centroid_withoutkalman, imgfeature2 );

%% calculate the ouliers
[ outliers_index ] = eliminatOutliers( centroid_withoutkalman, outlier_threshold, mode );
% plot(centroid_withoutkalman([outliers_index(2)],1),centroid_withoutkalman([outliers_index(2)],2),'b.');

centroid = centroid_withoutkalman;
centroid(outliers_index,:) = NaN;
% [ outliers_index ] = eliminatThreeSigmaOutliers( centroid_kalman_new );
clear centroid_kalman

kalmanindex = 0;
for k2 = 1:1:length(imgfeature2)   
    
    if isnan(centroid(k2,:))
        current_cent = [];
        centroid_kalman(k2,:) = [NaN, NaN];
        imgfeature2{k2}.kalmanresult = [NaN, NaN];
    else
        kalmanindex = kalmanindex + 1;
        current_cent = centroid(k2,:);
        [ kalmanresult, s_post, P_post ] = kalmanfilter( kalmanindex, current_cent', sigma_v, phi, s_post, P_post,[320,240], 2 );
        centroid_kalman(k2,:) = kalmanresult';
        if show
            imshow(imgfeature2{k2}.image);
            hold on
            plot(centroid_kalman(:,1),centroid_kalman(:,2),'r-');
            plot(kalmanresult(1),kalmanresult(2),'g*');
            pause(0.2) 
        end
        imgfeature2{k2}.kalmanresult = kalmanresult;
    end
    

%     if isfield(imgfeature2{k2},'centroidAvg')
%         current_cent = imgfeature2{k2}.centroidAvg{1};
%         withoutkalmanresult = current_cent;
%         centroid_withoutkalman(k2,:) = withoutkalmanresult';
%         imshow(imgfeature2{k2}.image);
%         hold on
%         plot(centroid_withoutkalman(:,1),centroid_withoutkalman(:,2),'r.');
%         plot(withoutkalmanresult(1),withoutkalmanresult(2),'g*');
%     end

end
%% interpolation the missing point
% exclude the outler
[centroid_kalman,HTOutlierIdx] = ExcludeHTOutliersInterpolation(centroid_kalman);
imgfeature2(HTOutlierIdx) = [];
centroid_kalman(HTOutlierIdx,:) = [];

for FrameIdx = 1:1:length(imgfeature2)
    imgfeature2{FrameIdx}.InterpolationResult = centroid_kalman(FrameIdx,:);
end

if show
    imshow(imgfeature2{end}.image);
    hold on
    plot(centroid_kalman(:,1),centroid_kalman(:,2),'r-');
    plot(kalmanresult(1),kalmanresult(2),'g*');
    pause(1)
end

end

