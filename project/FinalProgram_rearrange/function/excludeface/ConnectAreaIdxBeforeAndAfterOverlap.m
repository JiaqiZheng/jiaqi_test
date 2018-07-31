function [ OverlapingIdx,SubImageFeatures,FaceContourIdxVct ] = ConnectAreaIdxBeforeAndAfterOverlap( SubImageFeatures,show )
%find the index of the frames that before and after the hand-face overlap.
%the BeforeIdx is the index of the last frame that before the overlap
%the AfterIdx is the index of the first frame that after the overlap
%

FaceContourIdxVct = zeros(length(SubImageFeatures),1);
HandContourIdxVct = zeros(length(SubImageFeatures),1);
NewOldDistVct = zeros(length(SubImageFeatures),1);
% initialize the face center using the median of all the face
OldFaceCenterVect = ones(length(SubImageFeatures),2);
for IdxForFaceInitial = 1:1:length(SubImageFeatures)
    imgfeature = SubImageFeatures{IdxForFaceInitial};
    OldFaceCenterVect(IdxForFaceInitial,:) = getFaceCenter(imgfeature);
end
OldFaceCenter = median(OldFaceCenterVect,1);

for FrameIdx = 1:1:length(SubImageFeatures)
    imgfeature = SubImageFeatures{FrameIdx};
    % get the face center
    NewFaceCenter = getFaceCenter(imgfeature);
    [FaceCenter,NewOldDist] = getStableFaceCenter(NewFaceCenter,OldFaceCenter,20);
    SubImageFeatures{FrameIdx}.facebox{1}([1,2]) = FaceCenter - SubImageFeatures{FrameIdx}.facebox{1}(3)/2;
    OldFaceCenter = FaceCenter;
    % get the hand center
    HandCenter = imgfeature.InterpolationResult;
    % find the connect area that contains the center of the face in the two
    % images
%     SkinContour = bwboundaries(imgfeature.skinmask,'noholes'); % use contour in FindConnectAreaIdxAroundCenter
    SkinConnect = bwconncomp(imgfeature.skinmask); % use area in FindConnectAreaIdxAroundCenter
    FaceContourIdx = FindConnectAreaIdxAroundCenter(FaceCenter,SkinConnect,'Area');
    HandContourIdx = FindConnectAreaIdxAroundCenter(HandCenter,SkinConnect,'Area');
    

%     FaceAreaIdx = SkinConnect.PixelIdxList{FaceContourIdx};
%     NumPixelonFace = length(FaceAreaIdx);
%     NumPixelonFaceVct(FrameIdx) = NumPixelonFace;
%     
    NewOldDistVct(FrameIdx) = NewOldDist;
    FaceContourIdxVct(FrameIdx,:) = FaceContourIdx;
    HandContourIdxVct(FrameIdx,:) = HandContourIdx;
    if show
        figure(1)
        imshow(imgfeature.image);
        hold on;
        plot(FaceCenter(1),FaceCenter(2),'g*');
        plot(HandCenter(1),HandCenter(2),'r*');
        pause(1)
    end
end

OverlapingIdx = find(FaceContourIdxVct == HandContourIdxVct);

end
%% get the center of the face
function FaceCenter = getFaceCenter(imgfeature)
    FaceBoxImage = imgfeature.facebox;
    FaceCenter = FaceBoxImage{1}(1:2)+FaceBoxImage{1}(3)/2;
end

%% get stable face center
function [FaceCenter,NewOldDist] = getStableFaceCenter(NewFaceCenter,OldFaceCenter,DistThreshold)
% if the new face center is too far away from the previous face center
NewOldDist = pdist2(NewFaceCenter,OldFaceCenter);
if NewOldDist >= DistThreshold
    FaceCenter = OldFaceCenter;
else
    FaceCenter = NewFaceCenter;
end
end

%% find the connect area of face from the boundaries of the skin binary mask
function TargetIdx = FindConnectAreaIdxAroundCenter(CenterVect,SkinContourOrConnect,mode)
% the SkinContour is a cell saving all the contours of the connect are in
% the skin binary mask. It should be the result returned by the 
% SkinContour = bwboundaries(SkinMask)
% SkinConnect = bwconncomp(SkinMask);, which one is used depending on the
% chosen mode.
% the FaceCenter is the center of the detected face bounding box of the
% face detector.
% the mode can be 'Contour' or 'Area'. 'Contour' method is to justify if
% the center point within the contour. 'Area' method is to find the connect
% area that is closest to the center pixel.

switch mode
    case 'Contour'
        SkinContour = SkinContourOrConnect;
        ContourIdx2 = 1;
        while ~inpolygon(CenterVect(1),CenterVect(2),SkinContour{ContourIdx2}(:,2),SkinContour{ContourIdx2}(:,1)) &&...
              ContourIdx2 <= length(SkinContour)
            ContourIdx2 = ContourIdx2 + 1;
        end
        TargetIdx = ContourIdx2;
    case 'Area'
        SkinConnect = SkinContourOrConnect;
        minDistVect = ones(SkinConnect.NumObjects,1);
        for AreaIdx = 1:1:SkinConnect.NumObjects
            CandidateAreaIdx = SkinConnect.PixelIdxList{AreaIdx};
            [CandidateAreaSubY,CandidateAreaSubX] = ind2sub(SkinConnect.ImageSize,CandidateAreaIdx);
            CandidateAreaSub = [CandidateAreaSubX,CandidateAreaSubY];
            D = pdist2(CenterVect,CandidateAreaSub);
            minDistVect(AreaIdx) = min(D);
        end
        TargetIdx = find(minDistVect == min(minDistVect(:)));
end
    
end
