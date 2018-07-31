function [ NormDiff ] = getWeightedDiff( AlignIDCT, AlignDCT, ProjectW, MeanTargetTraj  )
%Get the weigthed sample-wise Euclidean distance of the testing trajectory
%and the mean trajectory of the target class
%   ProjectW is the first LDA projection vector corresponding to
%   discriminating the target class from others. 
%   MeanTargetTraj is the mean trajectory in the target class
%   AlignDCT is the DCT coefficients of the testing trajectory. Before
%   calculating DCT, the trajectory is aligned to the Procrustes model of
%   the target class
%   AlignIDCT is the trajectory gotten from inversing DCT coefficients of the testing trajectory. 
%   Before calculating DCT, the trajectory is aligned to the Procrustes model of
%   the target class. The IDCT will make the trajectory smoother. 
CommonSize = 30;

[WeightX,WeightY,WeightZ] = VisualizeIDCT(ProjectW,CommonSize,false); %AllDCTMatrixNormled(VideoIdx,:)'.*

WeightAll = (abs(WeightX)+abs(WeightY)+abs(WeightZ))/3;
WeightAll = FeatureScalingNormalize(WeightAll,0,1);

% get the weighted difference for all the trajectories

% inverse DCT with original trajectory length
OriginSampSize = size(AlignIDCT,1);
figure
[XAlignIdct,YAlignIdct,ZAlignIdct] = VisualizeIDCT(AlignDCT,OriginSampSize,true);
IDCTTrajOrigSize = [XAlignIdct;YAlignIdct;ZAlignIdct];
% resample the trajectory to the sampe size
TestTraj = interpolateXYZ(CommonSize,IDCTTrajOrigSize');
plot3(TestTraj(:,1),TestTraj(:,2),TestTraj(:,3));hold on;
plot3(MeanTargetTraj(:,1),MeanTargetTraj(:,2),MeanTargetTraj(:,3));
DirectDiff = TestTraj - MeanTargetTraj;
NormDiff = sqrt(sum(DirectDiff.^2,2))' * WeightAll;

end

