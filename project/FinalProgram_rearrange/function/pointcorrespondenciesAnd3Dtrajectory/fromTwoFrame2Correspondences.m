function [ SamplePFinal ] = fromTwoFrame2Correspondences( SamplePprevious,Pcurrent,n )
% getting the point correspondences from the two contours
% Pprevious and Pcurrent are two matrix saving the two contours which are
% from the contour from the previous frame and the contour from the current
% frame(in which we are looking for the points corresponding to the previous image)

% get the equal arclength spaced sampling
tic
LengthCurrent = length(Pcurrent);
if LengthCurrent < n
    LengthCurrent = n;
end
FullSamplePoint = 1/LengthCurrent:1/LengthCurrent:1;

FullSamplePcurrent = interparc(FullSamplePoint,Pcurrent(:,1),Pcurrent(:,2),'pchip');

diff_struct = ones(LengthCurrent,1);
meanPprevious = mean(SamplePprevious);
SamplePprevious = bsxfun(@minus,SamplePprevious,meanPprevious);

DownSamplePoint = round(1:LengthCurrent/n:LengthCurrent);

for i = 1:1:LengthCurrent
    % every iteration shift the sample by one
    FullSamplePcurrent = circshift(FullSamplePcurrent,1);
    
    SamplePcurrent = FullSamplePcurrent(DownSamplePoint,:);
    
    meanPcurrent = mean(SamplePcurrent);
    % remove the mean before calculating the affine transformation
    SamplePcurrent = bsxfun(@minus,SamplePcurrent,meanPcurrent);
    
    % estimate the affine transformation with
    tform = fitgeotrans(SamplePcurrent,SamplePprevious,'affine');
    A = tform.T';
    diff = eye(3) - A;
    diff_struct(i)= norm(diff,'fro');
end


startIdx = find(diff_struct == min(diff_struct));

% get the corresponding points
FullSampleFinal = circshift(FullSamplePcurrent,startIdx);
SamplePFinal = FullSampleFinal(DownSamplePoint,:);
% toc
end

