function [ OutputDataMatrix,MeanData,StdData ] = ZScoreNormalize( InputDataMatrix)
%Run Z-score standarization for each column of the DataMatrix
MeanData = mean(InputDataMatrix);
StdData = std(InputDataMatrix);
OutputDataMatrix = bsxfun(@times,(bsxfun(@minus,InputDataMatrix,MeanData)),ones(size(StdData))./StdData);

end

