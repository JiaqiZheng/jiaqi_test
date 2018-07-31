function [ imgfeature ] = CalculateCentroid( imgfeature, ellipsenum )
%Calculate the average center of mass of the masks. The mask using here
%come from the ellipse mask and skin mask, persummably this mask showing
%the pixels of hands.
%Qianli Feng, Oct 18, 2015

mask = bsxfun(@and, imgfeature.ellipsemask{ellipsenum}, imgfeature.skinmask);
mask = imfill(mask,'hole');
measures_mask = regionprops(mask,'Centroid','PixelList');
centroid_total = cell2mat({measures_mask.Centroid}');
totalarea = size(cell2mat({measures_mask.PixelList}'),1);

centroid_average = zeros(1,2);
for k1 = 1:1:size({measures_mask.PixelList},2)
    subarea = size(measures_mask(k1).PixelList,1);
    centroid_average = centroid_average + centroid_total(k1,:)*subarea;
end
centroid_average = centroid_average/totalarea;
imgfeature.centroidAvg{ellipsenum} = centroid_average;

end

