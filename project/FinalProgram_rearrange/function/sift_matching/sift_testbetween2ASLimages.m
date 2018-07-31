%% calculate the sift keypoints of two selected frames from different participants in the standard ASL

% 01_H_S
image_01 = imread('/Users/qianlifeng/Documents/MATLAB/final chose/01_H_S_3/raw_83.jpg');
image_01 = rgb2gray(image_01);

sift_image_01 = cv.SIFT(image_01);
siftwithimage = cv.drawKeypoints(image_01,sift_image_01);
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
descriptors_01 = extractor.compute(image_01,sift_image_01);
descriptors_02 = extractor.compute(image_02,sift_image_02);

%% matching the descriptor
matcher = cv.DescriptorMatcher('BruteForce');
matches = matcher.match(descriptors_01,descriptors_02);

im_matches = cv.drawMatches(image_01, sift_image_01, image_02, sift_image_02, matches);
imshow(im_matches);

