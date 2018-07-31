function [ IDCTcell,DCTMatrix,VideoSiftResultNoFace,dissimilarity,data_cell ] = TestFromVideo2DCT_ver3( videoStruct,CameraAlign,ProcusModel,show)
% run the feature(for classification) extraction algorithm for the videos
% version 2 update the function to have video directory as input (rather than folder directory)
% version 3 update the function to have the video structure as input (rather than video directory)
%                                       the video structure (videoStruct)
%                                       should contains frame, skinmask,
%                                       faceBB, as the input. 

% this script is main script for the 3D trajectory reconstruction algorithm
% Qianli Feng

%% SIFT features calculation, hand detection, get the attributes structure for each frame
% if number of input arguments is less than 5(means there is no data_cell)
% run the entire program, if there is data_cell input(means the
% corresponding points are already been extracted) then only run the SfM
% algorithm.

tic
VideoSiftResult = FromVideo2SIFTStruct(videoStruct,show);

%% run the kalman filter and interpolation

showIdx = 1:1:length(VideoSiftResult);
[ XYZtransformed_struct,VideoSiftResultAfterKalman ] = DetectionStruct2ThreeDTraj_ver2( VideoSiftResult,showIdx );

VideoSiftResultAfterKalman(cellfun(@isempty,VideoSiftResultAfterKalman(:))) = [];

%% run the substraction algorithm to eliminate the pixels on face
VideoSiftResultNoFace = cell(size(VideoSiftResultAfterKalman));
AllOverlapIdx = [];
for SubjectIdx =  1:1:length(VideoSiftResultAfterKalman);
    SubImageFeatures = VideoSiftResultAfterKalman{SubjectIdx};

    % figure('Color',[0,0,0]);maxfigure;
    [ SubImageFeatures,IfAllOverlapped ] = ExcludePixelsOnlyOnFace( SubImageFeatures,15,'UpdateTemplate',false );
    if ~IfAllOverlapped
        VideoSiftResultNoFace{SubjectIdx} = SubImageFeatures;
    else
        AllOverlapIdx = [AllOverlapIdx,SubjectIdx];
        disp(['The hand and face in video ',num2str(SubjectIdx),' are all overlapped. This program cannot solve this problem.'])
    end
end
% exclude the video with hand-face overlapped for all frames
VideoSiftResultNoFace(AllOverlapIdx) = [];

%% rerun the algorithm with a small modification(change the skin mask to no face mask)
[ VideoSiftResultNoFace ] = rerunHandDetectionWithNoFace( VideoSiftResultNoFace );
% toc

%% for visualization
% pauseTime = [0.2,1];
% mode1 = 'ImageWith2ndEllipseContour';
% showMasks( VideoSiftResultNoFace,mode1,pauseTime )
% % for show the trajectory with the original
% 
% XYZtrajectory = XYZtransformed_struct{1};
% Show3DTrajWithBody( XYZtrajectory,imgfeature2 );

%% get the hand mask and ellipse mask
% figure
pauseTime = [0.2,1];
mode3 = 'SkinMaskAnd2ndEllipseMask';
SkinAndEllipse = showMasks( VideoSiftResultNoFace,mode3,pauseTime,false );

%% get the contour point correspondences
data_cell = getPointCorrespondences(SkinAndEllipse,10);

%% run Structure from Motion and Functional Analysis
CommonSize = 30;
[XYZtransformed_struct,dissimilarity] = MannualLandmarksSfMtest(data_cell,CommonSize,ProcusModel,CameraAlign,false);

% using DCT to smooth
numBasis = 8;
[IDCTcell,DCTMatrix] = FunctionalAnalysis(XYZtransformed_struct,numBasis,false);

end

%%
function VideoSiftResult = FromVideo2SIFTStruct(videoStruct,show)
% Input the video or image sequence data from the give folder path and
% calculate the SIFT related features
% the input originfolderpath should contains the folders of videos, for the
% image sequence, this folder contains the folders of sequences. For the
% videos, this folder contains the video clips.

video_num = 1;
% calculate the sift keypoints and descriptors of all the frames in the video
try
    [ imgwithsift_structs_imitat ] = ExtractSIFTkeypoints_ver2( videoStruct, show, video_num);
catch ME
    if strcmp(ME.identifier,'MATLAB:nonStrucReference') && strcmp(ME.stack(1).name,'ExtractSIFTkeypoints')
      disp(['cannot detect any faces in all frames in video ',num2str(video_num)]);
      imgwithsift_structs_imitat = [];
    end
end

VideoSiftResult{1} = imgwithsift_structs_imitat;

VideoSiftResult(cellfun(@isempty,VideoSiftResult)) = [];

end
%% visualization part
function VisulizationOptions()

    % show the trajectory with nancy's half body
    SubjectNum = 5;
    XYZtrajectory = XYZtransformedIDCT_struct{SubjectNum};
    imgfeature3 = VideoSiftResultNoFace{SubjectNum};
    Show3DTrajWithBody( XYZtrajectory,imgfeature3 ); 

    % for show the hand masks
    pauseTime = [0.2,1];
    mode1 = 'OnlySkinMask';
    SkinMaskCell = showMasks( VideoSiftResultNoFace,mode1,pauseTime,true );

    % visualize the point correspondences
    DataCellForKalman = data_cell;
    for VideoNum = 1:1:length(data_cell);
        SubImageFeature = VideoSiftResultNoFace{VideoNum};
        for FrameNum = 1:1:length(SubImageFeature)
            FrameImageFeature = SubImageFeature{FrameNum};
            VideoData = data_cell{VideoNum};
            VideoDataKalman = DataCellForKalman{VideoNum};
            FrameData = VideoData(FrameNum,:);
            FrameDataKalman = VideoDataKalman(FrameNum,:);
            FrameDataVect = cell2mat(FrameData');
            FrameDataKalmanVect = cell2mat(FrameDataKalman');
            imshow(FrameImageFeature.image);
            hold on
            plot(FrameDataVect(:,1),FrameDataVect(:,2),'r.');
            plot(FrameDataKalmanVect(:,1),FrameDataKalmanVect(:,2),'g*');
            pause(1)
        end
        pause(2)
    end

end
