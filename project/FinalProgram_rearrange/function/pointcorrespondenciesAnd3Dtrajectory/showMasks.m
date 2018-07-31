function OutputStack = showMasks( NewImgfeatureStruct5,mode,pauseTime,show )
%Plot the sequence in the structure
% mode =    
%   'OnlyImage' - show the original image sequence for all the videos
%   'OnlySkinMask' - show only the skin mask
%   'Only2ndEllipseMask' - show the logical ellipse mask
%   'ImageAndSkinmask' - show the image masked by the skin mask
%   'ImageAnd2ndEllipseMask' - show the image masked by the recalculated ellipse mask
%   'SkinMaskAnd2ndEllipseMask' - show the skin mask and ellipse mask
%   'ImageWithSkinMaskAnd2ndEllipseMask' - show the image masked by the intersection of the skin mask and the ellipse mask
%   'ImageWith2ndEllipseContour' - show the original image sequence with the recalculated bounding ellipse
%
% pauseTime 
%   is a 2-entry vector whose the first one is the pause time for each 
%   image within a video, the second one is the pause time between videos.
OutputStack = cell(size(NewImgfeatureStruct5));
for subjectIdx = 1:1:length(NewImgfeatureStruct5)
    imgfeature2 = NewImgfeatureStruct5{subjectIdx};
    OutputSequence = cell(size(imgfeature2));
    for frameIdx = 1:1:length(imgfeature2)
        switch mode
            case 'OnlyImage'
                img = showOnlyImage(imgfeature2,frameIdx,show);
            case 'OnlySkinMask'
                img = showOnlySkinMask(imgfeature2,frameIdx,show);
            case 'Only2ndEllipseMask'
                img = showOnly2ndEllipseMask(imgfeature2,frameIdx, show);
            case 'ImageAndSkinmask'
                img = showImageAndSkinmask(imgfeature2,frameIdx,show);
            case 'ImageAnd2ndEllipseMask'
                img = showImageAnd2ndEllipseMask(imgfeature2,frameIdx,show);
            case 'SkinMaskAnd2ndEllipseMask'
                img = showSkinMaskAnd2ndEllipseMask(imgfeature2,frameIdx,show);
            case 'ImageWith2ndEllipseContour'
                img = showImageWith2ndEllipseContour(imgfeature2,frameIdx,show);
            case 'ImageWithSkinMaskAnd2ndEllipseMask'
                img = showImageWithSkinMaskAnd2ndEllipseMask(imgfeature2,frameIdx,show);
        end
        OutputSequence{frameIdx} = img;
        pause(pauseTime(1))
    end
    OutputStack{subjectIdx} = OutputSequence;
    pause(pauseTime(2))
end


end

function img = showOnlyImage(imgfeature2,frameIdx,show)
    img = imgfeature2{frameIdx}.image;
    if show;imshow(img);end
end

function img = showOnlySkinMask(imgfeature2,frameIdx,show)
    img = imgfeature2{frameIdx}.SkinMaskNoFace;
    if show;imshow(img);end
end

function img = showOnly2ndEllipseMask(imgfeature2,frameIdx,show)
    img = imgfeature2{frameIdx}.ellipsemask_2nd{1};
    if show;imshow(img);end
end

function img = showImageWith2ndEllipseContour(imgfeature2,frameIdx,show)
    img = imgfeature2{frameIdx}.image;
    handBoundingEllipse = imgfeature2{frameIdx}.ellipsecontour_2nd{1};
    if show;imshow(img);end
    hold on;
    if ~isnan(handBoundingEllipse)
        plot(handBoundingEllipse(:,1),handBoundingEllipse(:,2),'r-');
    end
end

function img = showImageAndSkinmask(imgfeature2,frameIdx,show)
    img = imgfeature2{frameIdx}.image;
    skinMask = imgfeature2{frameIdx}.SkinMaskNoFace;
    img = bsxfun(@times,img,uint8(skinMask));
    if show;imshow(img);end
end

function img = showImageAnd2ndEllipseMask(imgfeature2,frameIdx,show)
    img = imgfeature2{frameIdx}.image;
    EllipseMask = imgfeature2{frameIdx}.ellipsemask_2nd{1};
    img = bsxfun(@times,img,uint8(EllipseMask));
    if show;imshow(img);end
end

function mask = showSkinMaskAnd2ndEllipseMask(imgfeature2,frameIdx,show)
    SkinMask = imgfeature2{frameIdx}.SkinMaskNoFace;
    SkinMask = imfill(SkinMask,'holes');
    EllipseMask = imgfeature2{frameIdx}.ellipsemask_2nd{1};
    if ~isnan(EllipseMask)
        mask = SkinMask & EllipseMask;
        if show;imshow(mask);end
    else
        mask = NaN;
    end
end

function img = showImageWithSkinMaskAnd2ndEllipseMask(imgfeature2,frameIdx,show)
    img = imgfeature2{frameIdx}.image;
    SkinMask = imgfeature2{frameIdx}.SkinMaskNoFace;
    EllipseMask = imgfeature2{frameIdx}.ellipsemask_2nd{1};
    if ~isnan(EllipseMask)
        mask = SkinMask & EllipseMask;
        img = bsxfun(@times,img,uint8(mask));
        if show;imshow(img);end
    end
end

