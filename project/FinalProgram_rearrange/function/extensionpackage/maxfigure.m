function maxfigure( )
% maximize the current figure
pause(0.001);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);
end

