function [ sift_mat ] = DectionStruct2DataMatrix( imgfeature2,show )
% Get data matrix W for the Structure from Motion from the detection(attribute)
% structure
% multiple methods can be selected for extract W matrix
initialFrame = 'max';
sift_mat = SIFTkeypointMatch2DataMatrix(imgfeature2,initialFrame,show);

end

function sift_mat = SIFTkeypointMatch2DataMatrix(imgfeature2,initialFrame,show)
% get the data matrix from the SIFT keypoints matching
% the initialFrame is to define the

numSIFTkeypoints = zeros(1,length(imgfeature2));
for i = 1:1:length(imgfeature2)

    ellipsemask = imgfeature2{i}.ellipsemask_2nd{:};
    if ~isnan(ellipsemask) % if the re-calculated ellipse doesn't exist, skip.
        [ imgfeatureForMatch_temp ] = EliminateKeypointsOutMask( imgfeature2{i}, ellipsemask, 'non' );
        if ~isempty(imgfeatureForMatch_temp.sift_keypoints) % if the ellipse mask doesn't overlap overlap any keypoints(means it is wrong), then skip.
            imgfeature2{i} = imgfeatureForMatch_temp;
        end
    end

    numSIFTkeypoints(i) = length(imgfeature2{i}.sift_keypoints);
end

% match the SIFT keypoint
% find the frame with the most keypoints, treat it as a model to match
% or directly use the first frame as the model to match
if strcmp(initialFrame,'max')
    initial = find(numSIFTkeypoints == max(numSIFTkeypoints));
    initial = initial(1); % in this case the initial frame can be multiple, select the first one.(they should be very close to each other)
elseif strcmp(initialFrame,'first')
    initial = 1;%initial(1);
end

ellipsemask = imgfeature2{initial}.ellipsemask_2nd{:};
if ~isnan(ellipsemask)
    [ imgfeature_init ] = EliminateKeypointsOutMask( imgfeature2{initial}, ellipsemask, 'non' );
else
    imgfeature_init = imgfeature2{initial};
end
%     imshow(imgfeature_init.image);
%     a = cv.drawKeypoints(imgfeature_init.image,imgfeature_init.sift_keypoints);
%     imshow(a)

siftpt_cell = {imgfeature_init.sift_keypoints.pt};
%     cent_coord = imgfeature2{1}.centroidAvg{:};
sift_mat = cell(length(imgfeature2),length(siftpt_cell));

matcher = cv.DescriptorMatcher('BruteForce');

for i = 1:1:length(imgfeature2)        
    descriptor1 = imgfeature2{initial}.sift_descriptors;
    descriptor2 = imgfeature2{i}.sift_descriptors;

    matches = matcher.match(descriptor2,descriptor1);
    match_points = [matches.queryIdx;matches.trainIdx]' + 1; % queryIdx corresponding to the descriptor1 and the trainIdx corresponding the descriptor2

    % for write the corresponding point into matrix
    matchidx = match_points(:,1);
    initialidx = match_points(:,2);
    sift_mat(i,initialidx) = {imgfeature2{i}.sift_keypoints(matchidx).pt};

    if show
        im_matches = cv.drawMatches(imgfeature2{i}.image, imgfeature2{i}.sift_keypoints, imgfeature2{initial}.image, imgfeature2{initial}.sift_keypoints, matches);
        imshow(im_matches);
        pause(1)
    end
end

end