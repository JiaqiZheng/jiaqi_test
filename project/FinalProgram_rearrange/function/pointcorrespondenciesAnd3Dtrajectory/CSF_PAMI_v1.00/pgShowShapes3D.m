function pgShowShapes3D( S0, S3 )
%function pgPlayShapes3D( S0, S3 )
%
% S0, S3 are 3*T x n and has the structures selected for plotting
%
% Assumes the structures are already aligned

% sets the figure initial position, dimension, and background color
fig = gcf;
scrsz = get(0,'ScreenSize');
FACTOR = 1.0;
set(fig, 'Position', [1 scrsz(4)*FACTOR scrsz(3)*FACTOR scrsz(4)*FACTOR])
set(fig, 'Color', [0 0 0])
figure(fig)

% Plot footer
subplot('position', [ 0 0 1 0.08 ])
props = { 'FontSize', 18, 'Units','normalized', 'HorizontalAlignment','center', 'VerticalAlignment','middle'};
text( 0.3, 0.4,'{\bullet}  ground truth', 'Color', [1 1 1], props{:}, 'HorizontalAlignment','left' )
text( 0.6, 0.4, 'O  reconstruction', 'Color', [0 1 0], props{:}, 'HorizontalAlignment','center' )
axis off

% bounding box (zooming) of the displayed shapes
s = 4*mean( std(S0, 1, 2) );
bbox = s * [-1 1 -1 1 -1 1];

% main loop (display shape for each frame/image t)
T = size( S3 ) / 3;
for t = 1:T
    t3 = 3*t-[2 1 0];
    S0t = S0(t3,:);     % original 3D shape at time t
    S3t = S3(t3,:);     % reconstructed 3D shape at time t
    
    figure(fig), subplot('Position', [ 0.00 0.1 0.33 0.9 ]) %subplot(1,3,1),
    plot3D( S0t, S3t, 'VIEW 1', bbox, [ 0 0 1 ] )
    %camroll(90)
    figure(fig), subplot('Position', [ 0.34 0.1 0.33 0.9 ]) %subplot(1,3,2),
    plot3D( S0t, S3t, 'VIEW 2', bbox, [ 0 1 0 ] )
    %camroll(90)
    figure(fig), subplot('Position', [ 0.67 0.1 0.33 0.9 ]) %subplot(1,3,3),
    plot3D( S0t, S3t, 'VIEW 3', bbox, [ 1 0 0 ] )
    camroll(90)
    
    drawnow(), %pause(0.01)
    if ~ishandle(fig), return, end
end

% -----------------------------------------------------------------------------
function [] = plot3D( S0, S3, header, bbox, pos )

plot3( S0(1,:), S0(2,:), S0(3,:), 'w.', 'MarkerSize', 10 )
hold on
plot3( S3(1,:), S3(2,:), S3(3,:), 'go', 'MarkerSize',  8 )
hold off
axis equal xy off
axis(bbox)
view( pos );
title( header, 'Color', [0 1 0], 'FontSize', 18 )

% -----------------------------------------------------------------------------
