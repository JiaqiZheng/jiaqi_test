function [ NewSkinMask2,NewTemplateColorWindow ] = SolveHandFaceOverlap( SubImageFeatures,StartNum,SecondIdx,DiffThreshold,FaceContourIdxVct,mode,OriginTemplateColorWindow )
%solve the hand-face overlap problem by using the template matching and
%substraction. The function will firstly find 
%  mode can be 'ConstantTemplate' or 'UpdateTemplate'
SkinColorImage1 = SubImageFeatures{StartNum}.image;
SkinColorImage2 = SubImageFeatures{SecondIdx}.image;
SkinMask1 = SubImageFeatures{StartNum}.skinmask;
SkinMask2 = SubImageFeatures{SecondIdx}.skinmask;
[ SkinMask2 ] = DilateThenErosion( SkinMask2 );

%
% get the connected area for the skin mask
SkinConnect1 = bwconncomp(SkinMask1);
% SkinConnect2 = bwconncomp(SkinMask2);

% % get the contour of the each connect area in the skin mask
% SkinContour1 = bwboundaries(SkinMask1,'noholes');
% SkinContour2 = bwboundaries(SkinMask2,'noholes');

% get the index of the face blob for the frame with no overlap.
FaceContourIdx1 = FaceContourIdxVct(StartNum);
AreaConnectIdx1 = SkinConnect1.PixelIdxList{FaceContourIdx1};
% AreaConnectIdx2 = SkinConnect2.PixelIdxList{FaceContourIdx2};
% change linear index to subscript
[I,J] = ind2sub(size(SkinMask1),AreaConnectIdx1);

% get the window of gray scale image of the template(the one without hand-face overlap)
HeightRange = min(I):1:max(I);
WidthRange = min(J):1:max(J);
EnlargePixel = 20;
HeightRange2 = min(I)-EnlargePixel:1:max(I)+EnlargePixel;
WidthRange2 = min(J)-EnlargePixel:1:max(J)+EnlargePixel;

% generate the template of the only-face image and the test hand-face
% overlap image
% if use the constant template, just use the StartNum frame
% if use the update template, for the first frame use the StartNum frame
% and updated template later on
if strcmp(mode,'ConstantTemplate') || abs(StartNum - SecondIdx) == 1
    TemplateColorWindow(:,:,1) = SkinColorImage1(HeightRange,WidthRange,1);
    TemplateColorWindow(:,:,2) = SkinColorImage1(HeightRange,WidthRange,2);
    TemplateColorWindow(:,:,3) = SkinColorImage1(HeightRange,WidthRange,3);
else 
    TemplateColorWindow = OriginTemplateColorWindow;
end

QueryColorWindow(:,:,1) = SkinColorImage2(HeightRange2,WidthRange2,1);
QueryColorWindow(:,:,2) = SkinColorImage2(HeightRange2,WidthRange2,2);
QueryColorWindow(:,:,3) = SkinColorImage2(HeightRange2,WidthRange2,3);

TemplateGrayWindow = rgb2gray(TemplateColorWindow);
QueryGrayWindow = rgb2gray(QueryColorWindow);


% use openCV template matching, minimize squared difference

C = cv.matchTemplate(QueryGrayWindow,TemplateGrayWindow);

[y,x] = find(C == min(min(C)));
minusImage = QueryColorWindow(y:1:(y + size(TemplateGrayWindow,1))-1,x:1:(x + size(TemplateGrayWindow,2))-1,:);
AbsDiffImageWindow = imabsdiff(TemplateColorWindow,minusImage);

AbsDiffImageWindow = rgb2gray(AbsDiffImageWindow);
% imagesc(AbsDiffImageWindow);

BinaryDiffImageWindow = AbsDiffImageWindow > DiffThreshold;
% post processing the thresholded difference image, THIS STEP IS IMPROTANT
% FOR UPDATE TEMPLATE METHOD
BinaryDiffImageWindow = PostProcessingBinaryMask(BinaryDiffImageWindow);
% figure
% imshow(BinaryDiffImageWindow)


if strcmp(mode,'UpdateTemplate')
    NewTemplateColorWindow = UpdateTemplate(minusImage,BinaryDiffImageWindow,TemplateColorWindow);
end

NewSkinMask2 = SkinMask2;
NewSkinMask2(min(HeightRange2) + y : 1 : min(HeightRange2)+(y + size(TemplateGrayWindow,1))-1,...
             min(WidthRange2) + x : 1 : min(WidthRange2) + (x + size(TemplateGrayWindow,2))-1) = ...
         NewSkinMask2(min(HeightRange2) + y : 1 : min(HeightRange2)+(y + size(TemplateGrayWindow,1))-1,...
             min(WidthRange2) + x : 1 : min(WidthRange2) + (x + size(TemplateGrayWindow,2))-1) & BinaryDiffImageWindow;

% NewSkinMask2 = medfilt2(NewSkinMask2);
% NewSkinMask2 = DilateAndErosion(NewSkinMask2);

% figure;
% subplot(1,2,1);imshow(NewSkinMask2);title('after substraction');
% subplot(1,2,2);imshow(SkinMask2);title('before substraction');
% tightfig;

end

function NewTemplateColorWindow = UpdateTemplate(minusImage,BinaryDiffImageWindow,TemplateColorWindow)
% update the template image in each iteration
% minusImage is a subimage on the query image which has the same size as
% the template and is corresponding to the location with the lowest
% matching loss.
SE = strel('disk', 1, 4);
BinaryDiffImageWindow = imdilate(BinaryDiffImageWindow,SE);
a = minusImage .* repmat(uint8(~BinaryDiffImageWindow),[1,1,3]);
% figure;imshow(a)
b = TemplateColorWindow .* repmat(uint8(BinaryDiffImageWindow),[1,1,3]);
% figure;imshow(b)
NewTemplateColorWindow = a + b;
% figure;imshow(NewTemplateColorWindow)
end

function BinaryDiffImageWindow = PostProcessingBinaryMask(BinaryDiffImageWindow)
% post-process the binary image.

BinaryDiffImageWindow = ExcludeConnectAreaSmallerThanNPixels(BinaryDiffImageWindow,2);
% figure;imshow(BinaryDiffImageWindow)

% fill the holes in the binary image. This step is to improve the
% performance of erosion
BinaryDiffImageWindow = imfill(BinaryDiffImageWindow,'holes');
% figure;imshow(BinaryDiffImageWindow);

BinaryDiffImageWindow = ErosionThenDilate(BinaryDiffImageWindow);
% figure;imshow(BinaryDiffImageWindow);

BinaryDiffImageWindow = DilateThenErosion(BinaryDiffImageWindow);
% figure;imshow(BinaryDiffImageWindow);

BinaryDiffImageWindow = medfilt2(BinaryDiffImageWindow,[3,3]);
% figure;imshow(BinaryDiffImageWindow);
end