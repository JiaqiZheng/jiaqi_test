function [ OutputVect ] = FeatureScalingNormalize( InputVect, a, b )
%normalize the input vector(or matrix) between the range [a,b];

InputMax = max(InputVect(:));
InputMin = min(InputVect(:));

OutputVect = (InputVect - InputMin) ./ (InputMax - InputMin);
OutPutVect = OutputVect * (b - a) + a;

end

