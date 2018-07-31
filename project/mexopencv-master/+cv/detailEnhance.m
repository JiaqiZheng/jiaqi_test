%DETAILENHANCE  This filter enhances the details of a particular image
%
%     dst = cv.detailEnhance(src)
%     dst = cv.detailEnhance(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input 8-bit 3-channel image.
%
% ## Output
% * __dst__ Output image with the same size and type as `src`.
%
% ## Options
% * __SigmaS__ Range between 0 to 200. default 10
% * __SigmaR__ Range between 0 to 1. default 0.15
% * __FlipChannels__ whether to flip the order of color channels in input
%   `src` and output `dst`, between MATLAB's RGB order and OpenCV's BGR
%   (input: RGB->BGR, output: BGR->RGB). default false
%
% See also: cv.edgePreservingFilter, locallapfilt, localcontrast
%
