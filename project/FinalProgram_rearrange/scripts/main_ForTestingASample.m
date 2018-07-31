%% main script for runing on a new video

TargetSign = 'M_S_05';
% [ TargetMeanTrajectory,RestMeanTrajectory ] = getMeanTrajFromDCTCoefficients( TargetSign,false );
PreCalculateFolder = '/Users/qianlifeng/Documents/MATLAB/AASLIE/FinalProgram/PreCalculateData3/';
DirPreCalculateFile = dir([PreCalculateFolder,TargetSign,'*']);
load([PreCalculateFolder,DirPreCalculateFile.name]);

name = 'Qianli';
version = 'Test_good';
show = 'none';
folderpath = '/Users/qianlifeng/Academic/automatic ASL imitation evaluator/imitationvideo';
originfolderpath = [folderpath,'/',name,'/',version];

InputType = 'video';
CameraAlign = true;
ProcusModel = [{'predefined'},{ProcrusModel}];

% get the run the main program to get the trajectory and its DCT
% coefficients. 
t = cputime;
[ TestIDCTcells,TestDCT,TestFeatureResult,DissmilarityVect,data_cell ] = TestFromVideo2DCT( originfolderpath,InputType,CameraAlign,ProcusModel,show);
ElapsedCpuTime = cputime - t;

NormDiff = zeros(length(TestIDCTcells),1);
for videoNum = 1:1:length(TestIDCTcells);
    [ NormDiff(videoNum) ] = getWeightedDiff( TestIDCTcells{videoNum}, TestDCT(videoNum,:), ProjectW, ProcrusModel );% MeanTargetTraj  );
end

% testing

TestDataNormalized = bsxfun(@times,(bsxfun(@minus,TestDCT,NomalizationMean)),ones(size(NomalizationStd))./NomalizationStd);
TestNewFeature = zeros(size(TestDataNormalized,1),2);
TestNewFeature(:,1) = TestDataNormalized * ProjectW;
TestNewFeature(:,2) = TestDataNormalized * ProjectW2;

% TestLabel = 1;
% % for SVM prediction
% [predict_label, accuracy, dec_values] = libsvmpredict(TestLabel, TestNewFeature, SVMmodel);
% for Mahalanobis distance discriminant function
[predict_label] = ClassifyPredict(TestNewFeature,Classifier)

close all;
%% visualization
% Show3DTrajWithBody( TestIDCTcells{1},TestFeatureResult{1} )
%%
fig1=figure;
left=400; bottom=350 ; width=500 ; height=200;
pos=[left bottom width height];
axis off

c = colorbar;
c.Location = 'southoutside'; % using horizontal colorbar
c.Position = [0.05 0.3 0.9 0.4];
c.LineWidth = 2;
set(fig1,'OuterPosition',pos) 
cLB_x = c.Position(1); % the x of left bottom corner of the color bar
cLB_y = c.Position(2); % the y of left bottom corner of the color bar
cW = c.Position(3);
cH = c.Position(4);

MaxLabel = 1000;
MinLabel = 0;

if NormDiff > MaxLabel;
    NormDiff_show = MaxLabel;
else
    NormDiff_show = NormDiff;
end

TargetRatio = NormDiff_show/(MaxLabel - MinLabel);


Range = num2cell(MinLabel:100:MaxLabel);
c.TickLabelsMode = 'manual';
c.TickLabels = Range;

TargetRatioCB = TargetRatio * cW;

xi = cLB_x + TargetRatioCB;
xArrow = [xi xi];
yArrow = [cLB_y-0.13 cLB_y];

annotation('textarrow',xArrow,yArrow,'String',[num2str(NormDiff),' '],'FontSize',14);
annotation('rectangle',[xi, cLB_y, 0.0015, cH + 0.03]);
annotation('textbox',[cLB_x-0.04,cLB_y-0.3,0.3,0.2],'String','Perfectly','FitBoxToText','on','LineStyle','none','FontSize',11)
annotation('textbox',[cLB_x+cW-0.04,cLB_y-0.3,0.3,0.2],'String','Badly','FitBoxToText','on','LineStyle','none','FontSize',11)

if predict_label == 1;
    DetectResult = 'Success!';
else
    DetectResult = 'Try again';
end
annotation('textbox',[cLB_x+cW/2-0.06,cLB_y+cH,0.3,0.2],'String',DetectResult,'FitBoxToText','on','LineStyle','none','FontSize',14)




