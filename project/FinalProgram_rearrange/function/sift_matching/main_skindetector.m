%% eliminate the keypoints out of skin
% get the Gaussian Mixture Model
% [ GMM_skin, GMM_nonskin ] = getGMM();
load('/Users/qianlifeng/Documents/MATLAB/AASLIE/codes/sift_matching/GMMskin5.mat');
load('/Users/qianlifeng/Documents/MATLAB/AASLIE/codes/sift_matching/GMMnonskin5.mat');
GMM_skin = GMM_skin_struct{4};
GMM_nonskin = GMM_nonskin_struct{4};
threshold = 0.8;

[ video_bw ] = SkinDetectorGMM( video_color, GMM_skin, GMM_nonskin, threshold, show );
