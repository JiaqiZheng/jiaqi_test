function [ centroid_withoutkalman, imgfeature2 ] = SignFrames( numSIFTkeypoints, centroid_withoutkalman, imgfeature2 )
% Chosing sign frames by filtering out the frame with small number of SIFT
% keypoints. So far the "small" defined as less than a fraction of the max
% number of the sift keypoints during all the frames.
% Qianli Feng, Oct 26, 2015

sign_thresh = floor(max(numSIFTkeypoints)*0.35);
sign_indicator = numSIFTkeypoints>=sign_thresh;

% define the winow width of the median filter 
% winWidth = round(length(numSIFTkeypoints)*0.2);
% if mod(winWidth,2) == 0
%     winWidth = winWidth + 1;
% end
% sign_indicator = medfilt1(double(sign_indicator),winWidth);

sign_beginidx = min(find(sign_indicator));
sign_endidx = max(find(sign_indicator));

centroid_withoutkalman = centroid_withoutkalman(sign_beginidx:sign_endidx,:);
imgfeature2 = imgfeature2(sign_beginidx:sign_endidx);
end

