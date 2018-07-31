function [ SubstractStructCells,IfAllOverlapped ] = getIndexStruct( OverlappingIdx,FaceContourIdxVct )
%Get cells of the index structure for the image sbutraction for solving the
%hand-face overlap problem. The structures in the cells contains the start
%frame of the subtraction, the index of the frame for getting the image
%template and the order of the subtraction(forward +1 or backward -1).

SequenceLength = length(FaceContourIdxVct);
IfOverlappedIdx = zeros(1,SequenceLength);
IfOverlappedIdx(OverlappingIdx) = 1;

% initialize the states
LastState = IfOverlappedIdx(1);
LabelVect = ones(1,length(IfOverlappedIdx));
LastLabel = 1;

for ScanIdx = 2:1:length(IfOverlappedIdx)
    CurrentState = IfOverlappedIdx(ScanIdx);
    if CurrentState == LastState
        LabelVect(ScanIdx) = LastLabel;
    else
        LabelVect(ScanIdx) = LastLabel + 1;
        LastLabel = LastLabel + 1;
    end
    LastState = CurrentState;
end

OverlappedLabel = LabelVect(IfOverlappedIdx == 1);
UniqueOverlappedLabel = unique(OverlappedLabel);
NumIteration = length(UniqueOverlappedLabel);

SubstractStructCells = cell(1,NumIteration);
OverlappedIdx = [];
IfAllOverlapped = false;
for OverlapSegmentIdx = 1:1:NumIteration
    % get the index of current sequence of overlapped frames
    OverlappedIdx = find(LabelVect == UniqueOverlappedLabel(OverlapSegmentIdx));
    FirstIdx = min(OverlappedIdx);
    LastIdx = max(OverlappedIdx);

    % assign the parameters for subtraction
    if isempty(OverlappedIdx)
        TemplateFrameIdx = [];
        StartIdx = [];
        FrameIncrement = [];
        EndIdx = [];
    elseif FirstIdx == 1 && LastIdx < SequenceLength % if the first frame is overlapped
        TemplateFrameIdx = LastIdx + 1;
        StartIdx = LastIdx;
        FrameIncrement = -1;
        EndIdx = FirstIdx;
    elseif FirstIdx > 1 % if the first frame is not overlapped.
        TemplateFrameIdx = FirstIdx - 1;
        StartIdx = FirstIdx;
        FrameIncrement = 1;
        EndIdx = LastIdx;
    elseif FirstIdx == 1 && LastIdx == SequenceLength
        disp('all frames are overlapped, this function cannot deal with this problem.');
        IfAllOverlapped = true;
        return
    end
    SubtractStruct.TemplateFrameIdx = TemplateFrameIdx;
    SubtractStruct.StartIdx = StartIdx;
    SubtractStruct.EndIdx = EndIdx;
    SubtractStruct.FrameIncrement = FrameIncrement;
    SubstractStructCells{OverlapSegmentIdx} = SubtractStruct;

end

end

