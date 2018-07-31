function [ imgfeature ] = siftmask_ver2( imgfeature )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

n = 12;
ratio = 1.4;

if size(imgfeature.neighbour,2) == 2 
    imgfeature.handmask = cell(1,2);
    neighbour1_index = unique(imgfeature.neighbour{1});
    neighbour2_index = unique(imgfeature.neighbour{2});
    keypoints1 = imgfeature.sift_keypoints{1}(neighbour1_index);
    keypoints2 = imgfeature.sift_keypoints{1}(neighbour2_index);
    
    keypoints1_coord = cell2mat({keypoints1.pt}');
    keypoints2_coord = cell2mat({keypoints2.pt}');
    
    try
        % calculate the mask of the convex hull
        K1 = convhull(keypoints1_coord);
        poly_convhull1 = keypoints1_coord(K1,:);
        BW_mask1 = poly2mask(poly_convhull1(:,1),poly_convhull1(:,2),size(imgfeature.frames,1),size(imgfeature.frames,2));
        imgfeature.handmask{1} = BW_mask1;
        
        % create an ellipse cover the convex hull
        [ BW_ellipsemask1, xy ] = EllipseAroundConvHull( BW_mask1,n, ratio );
%         imshow(repmat(uint8(BW_mask1),1,1,3).*imgfeature.frames)
%         figure;
%         imshow(repmat(uint8(BW_ellipsemask1),1,1,3).*imgfeature.frames)
        imgfeature.ellipsemask{1} = BW_ellipsemask1;
        imgfeature.ellipsecontour{1} = xy;
        
        % do the same thing for the others convex hull
        K2 = convhull(keypoints2_coord);
        poly_convhull2 = keypoints2_coord(K2,:);
        BW_mask2 = poly2mask(poly_convhull2(:,1),poly_convhull2(:,2),size(imgfeature.frames,1),size(imgfeature.frames,2));
        imgfeature.handmask{2} = BW_mask2;
        
        [ BW_ellipsemask2, xy ] = EllipseAroundConvHull( BW_mask2,n, ratio );
%         imshow(repmat(uint8(BW_mask2),1,1,3).*imgfeature.frames)
%         figure;
%         imshow(repmat(uint8(BW_ellipsemask2),1,1,3).*imgfeature.frames)
        imgfeature.ellipsemask{2} = BW_ellipsemask2;
        imgfeature.ellipsecontour{2} = xy;
        
        % calculate the centers of mass for the two hand masks
        imgfeature = CalculateCentroid( imgfeature, 1 );
        imgfeature = CalculateCentroid( imgfeature, 2 );

        imshow(imgfeature.frames);
        hold on;
        plot(imgfeature.centroidAvg{1}(1),imgfeature.centroidAvg{1}(2),'r*');
        plot(imgfeature.centroidAvg{2}(1),imgfeature.centroidAvg{2}(2),'g+');
        
        imgfeature.ExistConv = true;
%         imshow(repmat(uint8(bsxfun(@or,BW_ellipsemask1,BW_ellipsemask2)),1,1,3).*imgfeature.frames)
    catch
%         disp('No enough unique points for convex hull');
        imgfeature.ExistConv = false;
    end

elseif size(imgfeature.neighbour,2) == 1 
    
    imgfeature.handmask = cell(1,1);
    neighbour1_index = unique(imgfeature.neighbour{1});
    keypoints1 = imgfeature.sift_keypoints{1}(neighbour1_index);
    
    keypoints1_coord = cell2mat({keypoints1.pt}');
    
    if size(keypoints1_coord,1) >= 3
        K1 = convhull(keypoints1_coord);
        poly_convhull1 = keypoints1_coord(K1,:);
        BW_mask1 = poly2mask(poly_convhull1(:,1),poly_convhull1(:,2),size(imgfeature.frames,1),size(imgfeature.frames,2));
        [ BW_ellipsemask, xy ] = EllipseAroundConvHull( BW_mask1,n, ratio );
%         imshow(BW_ellipsemask)
%         imshow(BW_mask1);
%         imshow(repmat(uint8(BW_mask1),1,1,3).*imgfeature.frames)
%         figure;
%         imshow(repmat(uint8(BW_ellipsemask),1,1,3).*imgfeature.frames)
        imgfeature.ellipsemask{1} = BW_ellipsemask;
        imgfeature.ellipsecontour{1} = xy;
        imgfeature.handmask{1} = BW_mask1;
        
        % calculat the average center of mass of the masks skin+ellipse
        % masks
        imgfeature = CalculateCentroid( imgfeature, 1 );
        imshow(imgfeature.frames);
        hold on;
        plot(imgfeature.centroidAvg{1}(1),imgfeature.centroidAvg{1}(2),'r*');
                
        imgfeature.ExistConv = true;
    elseif size(keypoints1_coord,1) < 3 && size(keypoints1_coord,1) > 0
%         disp('No enough unique points for convex hull');
        imgfeature.ExistConv = false;
    end
else
    imgfeature.ExistConv = false;
end



end

