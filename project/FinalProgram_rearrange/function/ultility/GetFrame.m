function [ frame ] = GetFrame( multiArray, index )
% get the frame from a multidimensional array.
inputSize = size(multiArray);
inputDim = length(inputSize);

eval(['frame = multiArray(',repmat(':,',[1,inputDim-1]),num2str(index),');']);

end

