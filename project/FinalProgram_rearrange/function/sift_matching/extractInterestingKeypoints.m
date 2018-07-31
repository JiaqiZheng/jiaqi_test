function [ imgwithSIFT ] = extractInterestingKeypoints( video_color, sift_structs, descriptors, matcher, num, num2, outlier_thresh, stiller_thresh, show )
%UNTITLED3 Summary of this function goes here 
%   Detailed explanation goes here

%% calculate the descriptor

frame1 = video_color(:,:,:,num);
sift_frame1 = sift_structs{num};
descriptors_frame1 = descriptors{num};

frame2 = video_color(:,:,:,num2);
sift_frame2 = sift_structs{num2};
descriptors_frame2 = descriptors{num2};


%% matching the descriptors

matches2 = matcher.match(descriptors_frame1,descriptors_frame2);

%% eliminate the uninteresting points

match_points = [matches2.queryIdx;matches2.trainIdx]' + 1; % the queryIdx corresponding to the first input argument in matcher.match(); the trainIdx corresponding to the second
match_points_frame1 = cell2mat({sift_frame1(match_points(:,1)).pt}'); % actually indexing the sift_frame_origin here is not necessary, since the query index is naturally ordered
match_points_frame2 = cell2mat({sift_frame2(match_points(:,2)).pt}');

[ matches_index_onlymove, match_points_index_onlymove ] = extractMovingKeypoints...
    ( match_points, match_points_frame1, match_points_frame2, outlier_thresh, stiller_thresh );

matches_onlymove = matches2(matches_index_onlymove);
descriptors_frame1_onlymove = descriptors_frame1(match_points_index_onlymove(:,1),:);
descriptors_frame2_onlymove = descriptors_frame2(match_points_index_onlymove(:,2),:);
sift_frame1_onlymove = sift_frame1(match_points_index_onlymove(:,1));
sift_frame2_onlymove = sift_frame2(match_points_index_onlymove(:,2));

imgwithSIFT(1) = struct('image',frame1,'sift_keypoints',sift_frame1_onlymove,'sift_descriptors',descriptors_frame1_onlymove,...
                                       'sift_keypoints_move',sift_frame1_onlymove,'sift_descriptors_move',descriptors_frame1_onlymove,...
                                       'sift_keypoints_full',sift_frame1,'sift_descriptors_full',descriptors_frame1);
imgwithSIFT(2) = struct('image',frame2,'sift_keypoints',sift_frame2_onlymove,'sift_descriptors',descriptors_frame2_onlymove,...
                                       'sift_keypoints_move',sift_frame2_onlymove,'sift_descriptors_move',descriptors_frame2_onlymove,...
                                       'sift_keypoints_full',sift_frame2,'sift_descriptors_full',descriptors_frame2);


%% show the results
% show the moving matched keypoints in the two frames
if strcmp(show,'moving') || strcmp(show,'all')
    figure(2)
    siftwithimage_frame1_onlymove = cv.drawKeypoints(frame1,sift_frame1_onlymove);
    imshow(siftwithimage_frame1_onlymove)

    siftwithimage_frame2_onlymove = cv.drawKeypoints(frame2,sift_frame2_onlymove);
    figure(3);
    imshow(siftwithimage_frame2_onlymove);
end
% % show the matching keypoints before outliers elimination
% im_matches = cv.drawMatches(frame1, sift_frame1, frame2, sift_frame2, matches2);
% imshow(im_matches);
% 
% % show the matching keypoints after outliers elimination moving keypoints extraction
% im_matches = cv.drawMatches(frame1, sift_frame1, frame2, sift_frame2, matches_onlymove);
% imshow(im_matches);
% 
% % show the new matching keypoints
% matches_onlymove_new = matcher.match(descriptors_frame1_onlymove,descriptors_frame2_onlymove);
% 
% im_matches_onlymove = cv.drawMatches(frame1, sift_frame1_onlymove, frame2, sift_frame2_onlymove, matches_onlymove_new);
% imshow(im_matches_onlymove);

end

