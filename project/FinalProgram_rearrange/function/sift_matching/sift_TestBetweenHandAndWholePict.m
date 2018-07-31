%% Matching between a hand of a subject and the whole sign from another subject
% both from the ASL database, 01 and 04 here. The hand is from 01 subject

% 01_H_S hand
image_01_hand = imread('/Users/qianlifeng/Documents/MATLAB/final chose/01_H_S_3/raw_83_hand.jpeg');
image_01_hand = rgb2gray(image_01_hand);

sift_image_01 = cv.SIFT(image_01_hand);
siftwithimage = cv.drawKeypoints(image_01_hand,sift_image_01);
figure
imshow(siftwithimage);

% 04_H_S
image_02 = imread('/Users/qianlifeng/Documents/MATLAB/final chose/04_H_S_3/raw_34.jpg');
image_02 = rgb2gray(image_02);

sift_image_02 = cv.SIFT(image_02);
siftwithimage = cv.drawKeypoints(image_02,sift_image_02);
figure
imshow(siftwithimage);

%% calculate the descriptor
extractor = cv.DescriptorExtractor('SIFT');
descriptors_01 = extractor.compute(image_01_hand,sift_image_01);
descriptors_02 = extractor.compute(image_02,sift_image_02);

%% matching the descriptor
matcher = cv.DescriptorMatcher('BruteForce');
matches = matcher.match(descriptors_01,descriptors_02);

im_matches = cv.drawMatches(image_01_hand, sift_image_01, image_02, sift_image_02, matches);
imshow(im_matches);

