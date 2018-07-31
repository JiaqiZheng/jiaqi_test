function [ imgfeature2 ] = EllipseRecalculate( imgfeature2, centroid_kalman, show )
%Recalculate the ellipse around the hand
%   Detailed explanation goes here

for i_frame = 1:1:length(imgfeature2)
        centroid_kalman_origin = centroid_kalman(i_frame,:);

        % use the size of face as the radius of the circle to find hands
        radius = (imgfeature2{i_frame}.facebox{:}(3)/2)*0.8;
        skin_mask1 = imgfeature2{i_frame}.skinmask;
        % calculate the circle mask
        theta = linspace(0,2*pi,16);
        costheta = cos(theta);
        sintheta = sin(theta);

        xy = [centroid_kalman_origin(1) + radius*costheta; centroid_kalman_origin(2) + radius*sintheta];
        xy = xy';
        BW_circlemask = poly2mask(xy(:,1),xy(:,2),size(skin_mask1,1),size(skin_mask1,2));
        % imshow(BW_circlemask)
        % imshow(skin_mask1)
        handmask_2nd = imfill(skin_mask1 & BW_circlemask,'hole');
        % imshow(handmask_2nd);
        if any(any(handmask_2nd))  % if the trajectory is far away from hand
            [ BW_ellipsemask_2nd, xy_2nd ] = EllipseAroundConvHull( handmask_2nd,12, 1.0 );
            imgfeature2{i_frame}.ellipsemask_2nd{1} = BW_ellipsemask_2nd;
            imgfeature2{i_frame}.ellipsecontour_2nd{1} = xy_2nd;
        else
            imgfeature2{i_frame}.ellipsemask_2nd{1} = NaN;
            imgfeature2{i_frame}.ellipsecontour_2nd{1} = NaN;
        end
        if show
            imshow(BW_ellipsemask_2nd)
            pause(0.2)
        end
end
end

