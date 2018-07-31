function [ videoStruct ] = MergeVideoStruct( videoStruct, fieldName, fieldValue, updateIdx )
% create or change the field in the videoStruct (by taking advantages of dynamic field name of matlab)
inputSize = size(fieldValue);
if inputSize(end) ~= length(updateIdx)
    disp('fieldValue does not match to the length of updateIdx');
    return
end

for loopIdx = 1:1:length(updateIdx)
    thisFieldIdx = updateIdx(loopIdx);
    videoStruct(thisFieldIdx).(fieldName) = GetFrame( fieldValue, loopIdx);
end

end

