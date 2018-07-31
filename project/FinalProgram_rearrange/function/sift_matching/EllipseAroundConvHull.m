function [ BW_ellipsemask, xy ] = EllipseAroundConvHull( BW_mask1,n, ratio )
%Calculate a ellipse around the convex hull mask and output the coordinates of
%the ellipse.
%
% BW_mask1 is a binary image with the convex hull set true value.
% n is the number of points to describe the ellipse
% ratio is the the ratio to enlarge the major and minor axis length.
%
% BW_ellipsemask is the binary image with the ellipse set true and the size
% is same as the input BW_mask1
% xy is a n-2 matrix of the coordinates on the ellipse.
%
% Qianli Feng, Oct 13, 2015
ellipse_measure = regionprops(BW_mask1,'Orientation','MajorAxisLength','MinorAxisLength','Eccentricity','Centroid','Solidity');

% to calculate the ellipse
theta = linspace(0,2*pi,n);
costheta = cos(theta);
sintheta = sin(theta);
% expand the major axis and minor axis by a ratio

% find the index with the largest major axis length. 
maxidx = find([ellipse_measure.MajorAxisLength] == max([ellipse_measure.MajorAxisLength]));

a = ratio*ellipse_measure(maxidx).MajorAxisLength/2;
b = ratio*ellipse_measure(maxidx).MinorAxisLength/2;

xy = [a*costheta;b*sintheta];
% calculate the rotation matrix and translation vector
theta_Rot = pi*ellipse_measure(maxidx).Orientation/180;

% the rotation is in the negative angle since the difference of the origin
% of the coordinate in math and image.
R = [cos(theta_Rot) sin(theta_Rot)
     -sin(theta_Rot)  cos(theta_Rot)];
xy = R*xy;

t_x = ellipse_measure(maxidx).Centroid(1);
t_y = ellipse_measure(maxidx).Centroid(2);

xy(1,:) = xy(1,:) + t_x;
xy(2,:) = xy(2,:) + t_y;

xy = xy';

BW_ellipsemask = poly2mask(xy(:,1),xy(:,2),size(BW_mask1,1),size(BW_mask1,2));


end

