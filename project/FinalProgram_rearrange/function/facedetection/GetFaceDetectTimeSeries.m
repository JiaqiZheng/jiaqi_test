function [ boxSizesPost, numFaces ] = GetFaceDetectTimeSeries( faceDetectResult )
% get the face detection time seiries of box position, box size and box
% numbers
numFaces = ones(length(faceDetectResult),1);
boxSizes = nan(length(faceDetectResult),4);
boxSizesPost = boxSizes;

for frameIdx = 1:1:length(faceDetectResult)
    numFaces(frameIdx) = size(faceDetectResult{frameIdx},2);
    
    % if number of faces is different than 1 put NaN in the size matrix
    if numFaces(frameIdx) == 1
        boxSizes(frameIdx,:) = faceDetectResult{frameIdx}{:};
    end
end

% using robust smoothing method discard outliers and fill-in the nan
for sizeIdx = 1:1:size(boxSizes,2)
    boxSizesPost(:,sizeIdx) = smooth(boxSizes(:,sizeIdx),'rlowess');
%     figure;
%     plot(boxSizes2(:,sizeIdx));
%     hold on
%     plot(boxSizes(:,sizeIdx));
end

end

