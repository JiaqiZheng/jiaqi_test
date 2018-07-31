function [ output_args ] = mainForTestingASample_fun_forweb ( videoPath, TargetSign , fh )
% main function for imitation video processing
% videoPath is the absolute directory for the video to be processed
% TargetSign is the sign name corresponding to the sign imitated in the
% input video
% fh is the file handle for the file pointer to save the function result in
% real time.

cd('/eecf/cbcsl/data100/Qianli2/AASLIE2/AASLIE/FinalProgram_rearrange/');
addpath(genpath('/eecf/cbcsl/data100/opencv-qianli/mexopencv-2.4'));

% [ TargetMeanTrajectory,RestMeanTrajectory ] = getMeanTrajFromDCTCoefficients( TargetSign,false );
PreCalculateFolder = '/eecf/cbcsl/data100/Qianli2/AASLIE2/AASLIE/FinalProgram_rearrange/PreCalculateData3/';
DirPreCalculateFile = dir([PreCalculateFolder,TargetSign,'*']);
load([PreCalculateFolder,DirPreCalculateFile.name]);

% % --- test input --- %
% TargetSign = 'M_S_05';  %signName;
% name = 'Qianli';
% version = 'Test_good';
% 
% folderpath = '/eecf/cbcsl/data100/Qianli2/automatic ASL imitation evaluator/automatic ASL imitation evaluator/imitationvideo';
% videoPath = [folderpath,'/',name,'/',version,'/','Qianli_newframe3__H_S_3_imitation.avi'];

InputType = 'video';
CameraAlign = true;
ProcusModel = [{'predefined'},{ProcrusModel}];
show = 'none';

%% read the video, skip the processing if the video does not satisfy processing criteria
[video_color, video_gray] = videoDir2FrameSeq(videoPath,'mmread',1);
[ faceBBs,numFaces ] = FaceDetectionMain( video_color );
video_bw = SkinColorDetectionMain(video_color,faceBBs,show);
threshFD = 4;
[ video_bw_move ] = SkinDetectionAndFrameDiff( video_color,video_gray, video_bw, threshFD, show );
%% combine the video frames, face bounding boxes and skin masks to 
videoStruct = [];
videoStruct = MergeVideoStruct(videoStruct,'frames',video_color,1:1:size(video_color,4));
videoStruct = MergeVideoStruct(videoStruct,'faceBB',reshape(faceBBs',[1,size(faceBBs,2),size(faceBBs,1)]),1:1:size(video_color,4));
videoStruct = MergeVideoStruct(videoStruct,'skinmaskFull',video_bw,1:1:size(video_color,4));
videoStruct = MergeVideoStruct(videoStruct,'skinmask',video_bw_move,1:1:size(video_color,4));

[state,reason] = IsLegitVideo(video_color);
if ~state
    fprintf(fh, 'Video Cannot be processed: %s\n', reason);
    return
end


%% processing the video
% get the run the main program to get the trajectory and its DCT
% coefficients. 
t = cputime;
[ TestIDCTcells,TestDCT,TestFeatureResult,DissmilarityVect,data_cell ] = TestFromVideo2DCT_ver3( videoStruct, CameraAlign,ProcusModel,show);

NormDiff = zeros(length(TestIDCTcells),1);
for videoNum = 1:1:length(TestIDCTcells);
    [ NormDiff(videoNum) ] = getWeightedDiff( TestIDCTcells{videoNum}, TestDCT(videoNum,:), ProjectW, ProcrusModel );% MeanTargetTraj  );
end

ElapsedCpuTime = cputime - t;

fprintf(fh, 'processing time is: %s\n', ElapsedCpuTime);
fprintf(fh, 'evalutaion score is: %s\n', NormDiff);

% testing

TestDataNormalized = bsxfun(@times,(bsxfun(@minus,TestDCT,NomalizationMean)),ones(size(NomalizationStd))./NomalizationStd);
TestNewFeature = zeros(size(TestDataNormalized,1),2);
TestNewFeature(:,1) = TestDataNormalized * ProjectW;
TestNewFeature(:,2) = TestDataNormalized * ProjectW2;

% TestLabel = 1;
% % for SVM prediction
% [predict_label, accuracy, dec_values] = libsvmpredict(TestLabel, TestNewFeature, SVMmodel);
% for Mahalanobis distance discriminant function
[predict_label] = ClassifyPredict(TestNewFeature,Classifier);

if predict_label == 1
    fprintf(fh, 'good! \n');
else
    fprintf(fh, 'not so good. \n');
end

close all;

%% visualization
% Show3DTrajWithBody( TestIDCTcells{1},TestFeatureResult{1} )
% %%
% fig1=figure;
% left=400; bottom=350 ; width=500 ; height=200;
% pos=[left bottom width height];
% axis off
% 
% c = colorbar;
% c.Location = 'southoutside'; % using horizontal colorbar
% c.Position = [0.05 0.3 0.9 0.4];
% c.LineWidth = 2;
% set(fig1,'OuterPosition',pos) 
% cLB_x = c.Position(1); % the x of left bottom corner of the color bar
% cLB_y = c.Position(2); % the y of left bottom corner of the color bar
% cW = c.Position(3);
% cH = c.Position(4);
% 
% MaxLabel = 1000;
% MinLabel = 0;
% 
% if NormDiff > MaxLabel;
%     NormDiff_show = MaxLabel;
% else
%     NormDiff_show = NormDiff;
% end
% 
% TargetRatio = NormDiff_show/(MaxLabel - MinLabel);
% 
% 
% Range = num2cell(MinLabel:100:MaxLabel);
% c.TickLabelsMode = 'manual';
% c.TickLabels = Range;
% 
% TargetRatioCB = TargetRatio * cW;
% 
% xi = cLB_x + TargetRatioCB;
% xArrow = [xi xi];
% yArrow = [cLB_y-0.13 cLB_y];
% 
% annotation('textarrow',xArrow,yArrow,'String',[num2str(NormDiff),' '],'FontSize',14);
% annotation('rectangle',[xi, cLB_y, 0.0015, cH + 0.03]);
% annotation('textbox',[cLB_x-0.04,cLB_y-0.3,0.3,0.2],'String','Perfectly','FitBoxToText','on','LineStyle','none','FontSize',11)
% annotation('textbox',[cLB_x+cW-0.04,cLB_y-0.3,0.3,0.2],'String','Badly','FitBoxToText','on','LineStyle','none','FontSize',11)
% 
% if predict_label == 1;
%     DetectResult = 'Success!';
% else
%     DetectResult = 'Try again';
% end
% annotation('textbox',[cLB_x+cW/2-0.06,cLB_y+cH,0.3,0.2],'String',DetectResult,'FitBoxToText','on','LineStyle','none','FontSize',14)

end

