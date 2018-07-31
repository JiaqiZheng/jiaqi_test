function [ video_bw ] = SkinColorDetectionMain( video_color, faceBBs, show )
% SkinColorDetectio main function. Serveral methods can be called for the
% skin color detection


if isempty(faceBBs)
    load('./GMMdata/GMM_13000skin6DB4.mat');
    load('./GMMdata/GMM_23000nonskin4.mat');
    threshGMM = 3.2;
    [ video_bw ] = SkinDetectorGMM( video_color, GMM_skin, GMM_nonskin, threshGMM, show );
else
    load('./GMMdata/GMM_13000skin6DBHSV4.mat');
    load('./GMMdata/GMM_23000nonskinHSV4.mat');
    threshold = 1.7;
    weight = 0.08;
    [ video_bw ] = SkinDetectorGMMInputFaceHSV( video_color, GMM_skin, GMM_nonskin, faceBBs, threshold, weight, show);
end


end

