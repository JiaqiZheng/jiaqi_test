function newXYZ = interpolateXYZ(aimLength,oldXYZ)
%% interpolate the trajectory w.r.t. time (make the trajectory in a same length for procustes analysis)
    % interpolate the trajectory to the length aimLength, the inteporlation is
    % by even time space but not even arclength
    % NOTE! interpac function may cause the point density changes, please
    % pay attention to that. If there is better method, it should be
    % substitue later. NOTE #2, have changed to the time interpolation
    
    originIndx = 1:1:length(oldXYZ);

    newXYindx = 1:(length(oldXYZ)-1)/(aimLength-1):length(oldXYZ);
    oldX = oldXYZ(:,1);
    oldY = oldXYZ(:,2);
    oldZ = oldXYZ(:,3);

    newX = interp1(originIndx,oldX,newXYindx,'pchip');
    newY = interp1(originIndx,oldY,newXYindx,'pchip');
    newZ = interp1(originIndx,oldZ,newXYindx,'pchip');
    newXYZ = [newX;newY;newZ]';

end

