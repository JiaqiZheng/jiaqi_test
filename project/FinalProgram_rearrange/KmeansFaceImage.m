function [ idx,faceRGB,nonfaceRGB ] = KmeansFaceImage( faceVector )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% vectorize faceImg
% faceVector = reshape(faceImg,size(faceImg,1)*size(faceImg,2),3);
idx = kmeans(double(faceVector),2);
% idxImg = reshape(idx,size(faceImg,1),size(faceImg,2));

% assuming face area is larger than non-face area in the face detection
% result
if sum(idx==1) > sum(idx==2)
    faceIdx = 1;
else
    faceIdx = 2;
end

faceRGB = faceVector(idx==faceIdx,:);
nonfaceRGB = faceVector(idx~=faceIdx,:);

% figure;imshow(idxImg)
end

