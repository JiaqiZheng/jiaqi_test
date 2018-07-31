function [ SubImageFeatures,IfAllOverlapped ] = ExcludePixelsOnlyOnFace( SubImageFeatures,DiffThreshold,mode,show )
%Exclude the pixels just on face, even when the hand-face 
%   Detailed explanation goes here
[ OverlappingIdx,SubImageFeatures,FaceContourIdxVct] = ConnectAreaIdxBeforeAndAfterOverlap( SubImageFeatures,show );
[ SubstractStructCells,IfAllOverlapped ] = getIndexStruct( OverlappingIdx,FaceContourIdxVct );

% run the template matching and subtraction on all the sequences of
% overlapping in the current video
NumOverlapSegment = length(SubstractStructCells);

if ~IfAllOverlapped % only run the program when there exsit frames that have no hand-face overlap problem
    if NumOverlapSegment > 0
        for OverlapSegmentIdx = 1:1:NumOverlapSegment

            SubtractStruct = SubstractStructCells{OverlapSegmentIdx};
            TemplateFrameIdx = SubtractStruct.TemplateFrameIdx;
            StartIdx = SubtractStruct.StartIdx;
            EndIdx = SubtractStruct.EndIdx;
            FrameIncrement = SubtractStruct.FrameIncrement;

            % for the frames with overlapped hand and face, do the image substraction
            % use the update template matching
            TemplateWindow = [];
            for SecondIdx = StartIdx:FrameIncrement:EndIdx
                [ NewSkinMask2,TemplateWindow ] = SolveHandFaceOverlap( SubImageFeatures,TemplateFrameIdx,SecondIdx,DiffThreshold,FaceContourIdxVct,mode,TemplateWindow);
                SubImageFeatures{SecondIdx}.SkinMaskNoFace = NewSkinMask2;
            %     figure;imshow(NewSkinMask2)
            %     SecondIdx = SecondIdx + 1; % for program modification in each iteration
            end
        end
        % for the frames without overlapped hand and face,  do the face blob
        % excluding
        FrameIdxNoOverlap = 1:1:length(SubImageFeatures);
        FrameIdxNoOverlap(OverlappingIdx) = [];

        for NoOverlapIdx = 1:1:length(FrameIdxNoOverlap)
            FrameIdx = FrameIdxNoOverlap(NoOverlapIdx);
            SkinConnect = bwconncomp(SubImageFeatures{FrameIdx}.skinmask);
            FaceAreaIdx = FaceContourIdxVct(FrameIdx);
            FaceAreaPixelIdx = SkinConnect.PixelIdxList{FaceAreaIdx};
            NewSkinMask2 = SubImageFeatures{FrameIdx}.skinmask;
            NewSkinMask2(FaceAreaPixelIdx) = false;
        %     figure;imshow(NewSkinMask2)
            SubImageFeatures{FrameIdx}.SkinMaskNoFace = NewSkinMask2;
        end
    else % if the sequence are all non-overlapped just exclude the faces
        FrameIdxNoOverlap = 1:1:length(SubImageFeatures);
        FrameIdxNoOverlap(OverlappingIdx) = [];

        for NoOverlapIdx = 1:1:length(FrameIdxNoOverlap)
            FrameIdx = FrameIdxNoOverlap(NoOverlapIdx);
            SkinConnect = bwconncomp(SubImageFeatures{FrameIdx}.skinmask);
            FaceAreaIdx = FaceContourIdxVct(FrameIdx);
            FaceAreaPixelIdx = SkinConnect.PixelIdxList{FaceAreaIdx};
            NewSkinMask2 = SubImageFeatures{FrameIdx}.skinmask;
            NewSkinMask2(FaceAreaPixelIdx) = false;
        %     figure;imshow(NewSkinMask2)
            SubImageFeatures{FrameIdx}.SkinMaskNoFace = NewSkinMask2;
        end
    end
    
else
    return
    
end

if show
    for ShowFrameIdx = 1:1:length(SubImageFeatures)
        FirstSkinMask = SubImageFeatures{ShowFrameIdx}.skinmask;
        SecondSkinMask = SubImageFeatures{ShowFrameIdx}.SkinMaskNoFace;
        subplot(1,2,1)
        imshow(FirstSkinMask);
        title('\color{white}Before substraction','FontSize', 18)
        subplot(1,2,2)
        imshow(SecondSkinMask);
        title('\color{white}After substraction','FontSize', 18)
        pause(0.2)
    end
end
    
end

