function [ videoStruct ] = ExtractInterestingKeypoints_ver2( videoStruct, matcher, num1, num2, outlier_thresh, stiller_thresh, show )
% extract the keypoints is not moving or moved too much
% version2 changes the input to the videoStruct, excluding the outlier
% points rather than preserving the inlier points (these two are different
% since not all the points in both frames are matched).
% Nov, 25, 2016

%% calculate the descriptor

frame1 = videoStruct(num1).frames;
sift1pre = videoStruct(num1).sift_keypoints{1};
descriptors1pre = videoStruct(num1).sift_descriptors{1};

frame2 = videoStruct(num2).frames;
sift2pre = videoStruct(num2).sift_keypoints{1};
descriptors2pre = videoStruct(num2).sift_descriptors{1};


%% matching the descriptors

matches2 = matcher.match(descriptors1pre,descriptors2pre);

%% eliminate the uninteresting points

match_points = [matches2.queryIdx;matches2.trainIdx]' + 1; % the queryIdx corresponding to the first input argument in matcher.match(); the trainIdx corresponding to the second
match_points_frame1 = cell2mat({sift1pre(match_points(:,1)).pt}'); % actually indexing the sift_frame_origin here is not necessary, since the query index is naturally ordered
match_points_frame2 = cell2mat({sift2pre(match_points(:,2)).pt}');

[ idxMove, idxPairMove,idxPairOutlier ] = ExtractMovingKeypoints_ver2...
    ( match_points, match_points_frame1, match_points_frame2, outlier_thresh, stiller_thresh );

sift1post = sift1pre;
descriptors1post = descriptors1pre;
sift2post = sift2pre;
descriptors2post = descriptors2pre;

sift1post(idxPairOutlier(:,1)) = [];
descriptors1post(idxPairOutlier(:,1),:) = [];
sift2post(idxPairOutlier(:,2)) = [];
descriptors2post(idxPairOutlier(:,2),:) = [];

videoStruct(num1).sift_keypoints{1} = sift1post;
videoStruct(num1).sift_descriptors{1} = descriptors1post;
videoStruct(num2).sift_keypoints{1} = sift2post;
videoStruct(num2).sift_descriptors{1} = descriptors2post;

videoStruct(num1).sift_keypoints_move{1} = sift1post;
videoStruct(num1).sift_descriptors_move{1} = descriptors1post;
videoStruct(num2).sift_keypoints_move{1} = sift2post;
videoStruct(num2).sift_descriptors_move{1} = descriptors2post;

% descriptors_frame1_onlymove = descriptors1pre(idxPairMove(:,1),:);
% descriptors_frame2_onlymove = descriptors2pre(idxPairMove(:,2),:);
% sift_frame1_onlymove = sift1pre(idxPairMove(:,1));
% sift_frame2_onlymove = sift2pre(idxPairMove(:,2));
% 
% imgwithSIFT(1) = struct('image',frame1,'sift_keypoints',sift_frame1_onlymove,'sift_descriptors',descriptors_frame1_onlymove,...
%                                        'sift_keypoints_move',sift_frame1_onlymove,'sift_descriptors_move',descriptors_frame1_onlymove,...
%                                        'sift_keypoints_full',sift1pre,'sift_descriptors_full',descriptors1pre);
% imgwithSIFT(2) = struct('image',frame2,'sift_keypoints',sift_frame2_onlymove,'sift_descriptors',descriptors_frame2_onlymove,...
%                                        'sift_keypoints_move',sift_frame2_onlymove,'sift_descriptors_move',descriptors_frame2_onlymove,...
%                                        'sift_keypoints_full',sift2pre,'sift_descriptors_full',descriptors2pre);
% 

%% show the results
% show the moving matched keypoints in the two frames
if strcmp(show,'moving') || strcmp(show,'all')
    figure(2)
    siftwithimage1 = cv.drawKeypoints(frame1,sift1post);
    imshow(siftwithimage1)

    siftwithimage2 = cv.drawKeypoints(frame2,sift2post);
    figure(3);
    imshow(siftwithimage2);
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

