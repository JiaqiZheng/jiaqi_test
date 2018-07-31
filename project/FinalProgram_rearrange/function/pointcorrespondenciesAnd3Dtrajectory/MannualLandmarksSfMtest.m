function [XYZtransformed_struct,dissimilarity,model1] = MannualLandmarksSfMtest(sift_cells2,firstNum,ProcrusModel,CameraAlign,show)
% check the SfM algorithm using the manual landmarks

%% Start the manual marking algorithm
% n = 6;
% sift_cells31 = MarkLandmarks(OriginSiftResults_struct31,n);


%% input the point correspondencies
% sift_cell5two = read2SignsLandmarks();
% sift_cells4 = {sift_mat51,sift_mat52,sift_mat53,sift_mat54};
dissimilarity = [];
model1 = [];
XYZtransformed_struct = cell(length(sift_cells2),length(ProcrusModel)-1);
%% Structure from motion
for VideoNum = 1:1:length(sift_cells2)
    
    % from landmarks to data matrix
    W = landmarks2datamat(sift_cells2,VideoNum,firstNum);
    % exclude the columns with all NaN
    W = excludeNaNColumn(W,0.5);
    %% SFM

    % using ellipse
%     W = nan(2*length(imgfeature2),12);
%     for k3 = 1:1:length(imgfeature2)
%         imgfeature = imgfeature2{k3};
%         ellipseCountour = imgfeature.ellipsecontour_2nd{1};
%         W(2*k3-1:2*k3,:) = ellipseCountour';
%     end

% 
%     % get the M from paulo's rigid structure from motion
%     W = zeros(2*size(centroid_kalman,1),1);
%     W(1:2:end) = centroid_kalman(:,1);
%     W(2:2:end) = centroid_kalman(:,2);
% 
    % paulo's rigid structure from motion
    [ M,S ] = getM( W, show );
    
    %% check the reprojection trajectory 
    
    
    %% recover the shape in the real size
    % from the anthropometry data, the mean of length of index finger of female is 67mm
    % the length of index is the distance between the first and second
    % points in sift_cell2

%    % uncomment the following lines when to r
%     IndexDistS = sqrt(sum((S(1:3,1) - S(1:3,2)).^2));
%     IndexDist_mean = 67; % unit in mm
    
    scale_factor = 1;%IndexDist_mean/IndexDistS;
    
    [M,S,t_x,t_y] = recoverTrueUnit(M,S,scale_factor,CameraAlign); % using the alignment of the camera
        
    % use the t rather than mean 
    X = t_x;
    Y = t_y;
  
    %% recover the depth
    Z_temp = recoverDepth(M);
    
    %% exclude the noise point
    Z_temp = excludeNoiseDepth(Z_temp);
    if show
        figure(10);
        subplot(3,5,VideoNum);
        plot(Z_temp)
    end
     %% interpolate the all trajectories to the same length
    aimLength = 30; % the length of the trajectory after interpolation
    oldXYZ = [X,Y,Z_temp']; 
    newXYZ = interpolateXYZ(aimLength,oldXYZ);
    
    %% procustes analysis for align all the trajectories to the one of first subjector
    if strcmp(ProcrusModel{1},'first') % ProcrusModel{1} is a cell saving the mode of alignment and if it is predefined mode, the ProcrusModel{2} saves the predefined trajectory
        % run this comment when runing all subjects
        if VideoNum == 1
            % using DCT smoothing
            [model1,~] = FunctionalAnalysis({newXYZ},8,false);
            model1 = model1{1};
        end
        if CameraAlign
            % if align camera motion in the first frame, do translation and
            % reflection alignemnt
            [ XYZtransformed{1},D ] = ProcrusCameraAlign( model1, newXYZ );
            dissimilarity(VideoNum) = D;
        else
            [D,XYZtransformed{1}] = procrustes(model1,newXYZ);
            dissimilarity(VideoNum) = D;
        end
    elseif strcmp(ProcrusModel{1},'predefined')
        % run this line when only runing a subject
        model1 = ProcrusModel{2};
        if CameraAlign
            % if align camera motion in the first frame, do translation and
            % reflection alignemnt
            [ XYZtransformed{1},D ] = ProcrusCameraAlign( model1, newXYZ );
            dissimilarity(VideoNum) = D;
        else
            [D,XYZtransformed{1}] = procrustes(model1,newXYZ);
            dissimilarity(VideoNum) = D;
        end
    end
    
    
    for ModelNum = 1:1:length(XYZtransformed)
        % resample back to the original length of the signal
        XYZtransformedOrigLength = interpolateXYZ(length(oldXYZ),XYZtransformed{ModelNum});
        if ~CameraAlign
            % use the post-procrustes one     
            XYZtransformed_temp = XYZtransformedOrigLength; % use the signel that resampled to original length
%             XYZtransformed_temp = XYZtransformed{ModelNum}; % using the all 30pts trajectory will eliminate most of the discriminant information
        else
            % use the pre-procrustes one
%             XYZtransformed_temp = oldXYZ;
            XYZtransformed_temp = XYZtransformed{1};
        end
        XYZtransformed_struct{VideoNum,ModelNum} = XYZtransformed_temp;
    end

    %% show the trajectories 
    if show
        figure(10);
        hold on
        subplot(3,5,VideoNum);
        plot3(XYZtransformed_temp(:,1),XYZtransformed_temp(:,2),XYZtransformed_temp(:,3),'r-'); 
        axis ij
        axis([0,640,0,480,0,max(Z)])
        grid on
    end
end
% resample to 30 pts
for i = 1:1:length(XYZtransformed_struct)
    testTraj = XYZtransformed_struct{i};
    testTraj = interpolateXYZ(30,testTraj);
    XYZtransformed_struct{i} = testTraj;
end

% %% check the image 
% for k1 = 3:4%1:1:length(sift_cells3)
%     imgfeature2 = OriginSiftResults_struct31{k1}(2,1:end-1);
%     figure
%     sift_mat = sift_cells3{k1};
%     for n1 = 1:1:size(sift_mat,2)
%         a = sift_mat(:,n1);
%         b = cell2mat(a);
% %         plot(b(:,1),b(:,2));
%         figure
%         imshow(imgfeature2{n1}.image)
%         hold on
%         plot(b(:,1),b(:,2),'r*');
%         pause(1)
%     end
%     figure
%     for n1 = 21%1:1:size(sift_mat,1)
%         a = sift_mat(n1,:);
%         b = cell2mat(a');
% %         image = imgfeature2{n1}.image;
% %         plot(b(:,1),b(:,2));
%         figure
%         imshow(imgfeature2{n1}.image)
%         hold on
%         plot(b(:,1),b(:,2),'r*');
% %         axis ij
%         pause(1)
%     end 
% end
end

%%
function sift_cells2 = MarkLandmarks(OriginSiftResults_struct31,n)
% n is the number of the landmarks going to be labeled
    for k4 = 1:1:length(OriginSiftResults_struct31)
       imgfeature2 = OriginSiftResults_struct31{k4}(2,1:end-2);
       for k5 = 1:1:length(imgfeature2)
           imshow(imgfeature2{k5}.image)
           [x,y] = ginputc(n,'Color','r');
           handlandmarks = [x,y];
           sift_mat311(k5,:) = mat2cell(handlandmarks,ones(1,6),2)';
           sift_cells2{k4} = sift_mat311;     
       end
       clear sift_mat311
    end
end

%% 
function sift_cell5two = read2SignsLandmarks()
    % for the suject #2 motion #5
    sift_mat2(1,:) = {[482,294],[484,303],[470,316],[445,327],[447,320],[447,310]};
    sift_mat2(2,:) = {[476,296],[479,305],[463,325],[443,336],[442,328],[445,318]};
    sift_mat2(3,:) = {[469,300],[470,306],[458,327],[436,337],[436,331],[436,321]};
    sift_mat2(4,:) = {[460,292],[463,301],[448,320],[429,331],[427,326],[426,317]};
    sift_mat2(5,:) = {[445,278],[449,285],[437,307],[416,322],[414,316],[411,305]};
    sift_mat2(6,:) = {[424,260],[428,269],[419,291],[404,306],[396,302],[392,292]};
    sift_mat2(7,:) = {[401,242],[407,251],[398,274],[382,291],[374,286],[369,277]};
    sift_mat2(8,:) = {[372,227],[379,234],[376,260],[357,277],[347,270],[338,258]};
    sift_mat2(9,:) = {[341,211],[345,220],[337,246],[328,263],[314,261],[304,251]};
    sift_mat2(10,:) = {[302,202],[311,207],[306,234],[295,253],[285,250],[274,246]};
    sift_mat2(11,:) = {[264,197],[275,207],[268,232],[261,249],[250,247],[236,244]};
    sift_mat2(12,:) = {[229,200],[239,206],[234,235],[229,251],[212,251],[198,245]};
    sift_mat2(13,:) = {[192,204],[202,211],[199,238],[194,258],[181,259],[166,253]};
    sift_mat2(14,:) = {[160,218],[170,224],[167,254],[157,268],[147,276],[134,265]};

    %% for the subject #1 motion #5
    sift_mat1(1,:) = {[468,255],[459,268],[428,284],[431,269],[436,258]};
    sift_mat1(2,:) = {[463,255],[454,265],[421,282],[429,268],[430,257]};
    sift_mat1(3,:) = {[452,240],[443,254],[418,270],[420,256],[425,244]};
    sift_mat1(4,:) = {[436,218],[427,232],[404,252],[404,236],[407,223]};
    sift_mat1(5,:) = {[411,192],[406,204],[385,232],[381,216],[383,202]};
    sift_mat1(6,:) = {[382,172],[382,182],[360,212],[354,195],[354,182]};
    sift_mat1(7,:) = {[346,153],[350,166],[329,195],[319,179],[317,165]};
    sift_mat1(8,:) = {[312,137],[313,149],[293,186],[280,169],[280,157]};
    sift_mat1(9,:) = {[276,133],[279,145],[264,180],[248,163],[240,151]};
    sift_mat1(10,:) = {[238,136],[244,144],[230,182],[212,170],[206,159]};
    sift_mat1(11,:) = {[202,147],[213,154],[198,191],[180,179],[169,171]};
    sift_mat1(12,:) = {[169,169],[173,173],[170,213],[144,204],[140,193]};
    sift_mat1(13,:) = {[138,197],[148,202],[142,241],[121,232],[110,223]};
    sift_mat1(14,:) = {[111,298],[122,245],[121,276],[97,272],[87,262]};
    sift_mat1(15,:) = {[88,281],[99,283],[108,307],[83,306],[72,297]};
    % sift_mat1(16,:) = {[86,294],[95,297],[102,322],[82,319],[72,311]};
    % sift_mat1(17,:) = {[87,299],[99,203],[104,325],[83,323],[74,314]};
    % sift_mat1(18,:) = {[90,299],[102,300],[102,328],[84,326],[74,313]};
    % sift_mat1(19,:) = {[91,301],[103,304],[104,326],[86,324],[74,316]};
    
    sift_cell5two = {sift_mat1,sift_mat2};
end

%% from landmarks to data matrix
function W = landmarks2datamat(sift_cells2,k1,firstNum)
    sift_mat = sift_cells2{k1};
    % interpolation the data matrix to get the same length of each
    % landmarks trajectory
%     sift_mat = intepolateLandmarksTraject(sift_mat,firstNum);
    % transfer the matching matrix into the data matrix
    W = nan(2*size(sift_mat,1),size(sift_mat,2));
    for i = 1:1:size(sift_mat,1)
        for j = 1:1:size(sift_mat,2)
            if ~isempty(sift_mat{i,j})
                W([2*i-1,2*i],j) = cell2mat(sift_mat(i,j))';
            end
        end
    end
end

%% recover the true shape size using the scale ambiguity
function [M,S,t_x,t_y] = recoverTrueUnit(M,S,scale_factor,Align)
    if Align
        M1 = M(1:2,1:3);
        a1 = M1(1,:);
        a2 = M1(2,:);
        a3 = cross(a1,a2);
        M1_full = [a1;a2;a3*(norm(a1)/norm(a3))];
        TarM1 = [1 0 0;0 1 0;0 0 1];
        R = M1_full^-1*TarM1;

        Mafter = M(:,1:3) * R;
        Safter = S(1:3,:)'*R^-1;
        M(:,1:3) = Mafter;
        S(1:3,:) = Safter';
    end
    S = S*scale_factor;
    M = M/scale_factor;
       
    i_x = 1:2:length(M);
    i_y = 2:2:length(M);
    t_x = M(i_x,4);
    t_y = M(i_y,4);

end



%% recover the depth
function Z_temp = recoverDepth(M)
    % for the scaled orthographical projection camera model, the recover
    % the depth by inverse the scale of the A. 
    scale_idx = 1:2:length(M);
    for k5 = 1:1:length(scale_idx)
        scale(k5) = norm(M(scale_idx(k5),1:3));
    end
    scale = medfilt1(scale,3);
    Z_temp = 1./scale;
end

%% eliminate the outliers in the depth signal
function Z_temp = excludeNoiseDepth(Z_temp)
    % apply median filter on the depth signal if the depth is larger than the 3
    % median absolute deviation then treat it as outliers
    
    dist = abs(Z_temp - median(Z_temp));
    signalidx = 1:1:length(Z_temp);
%     outlieridx = find(dist >= median(Z_temp) + 3*mad(Z_temp,1));
    [ outlieridx ] = eliminatOutliers( Z_temp', 2, 'IterativeGaussian' );
    Z_temp2 = Z_temp;
    Z_temp2(outlieridx) = [];
    signalidx(outlieridx) = [];
    Z_outlier = interp1(signalidx,Z_temp2,outlieridx,'pchip');
    Z_temp(outlieridx) = Z_outlier;
end


%% interpolate trajectories of each landmarks in the cell matrix
function sift_mat = intepolateLandmarksTraject(sift_mat,aimLength)
% interpolate the trajectories to the same size for all the landmarks each
% video
    for landmarksidx = 1:1:size(sift_mat,2)
        landmarksTraj_single = cell2mat(sift_mat(:,landmarksidx));
        newXY = interpolateXY(aimLength,landmarksTraj_single);
        landmarksTraj_full(:,landmarksidx) = mat2cell(newXY,ones(length(newXY),1),2);
    end
    sift_mat = landmarksTraj_full;
end
%% interpolation XY
function newXY = interpolateXY(aimLength,landmarksTraj)
    originIndx = 1:1:length(landmarksTraj);

    newXYindx = 1:(length(landmarksTraj)-1)/(aimLength-1):length(landmarksTraj);
    oldX = landmarksTraj(:,1);
    oldY = landmarksTraj(:,2);


    newX = interp1(originIndx,oldX,newXYindx,'pchip');
    newY = interp1(originIndx,oldY,newXYindx,'pchip');

    newXY = [newX;newY]';
end

%% calculate and show the reprojection trajectory and the original image
% function calculateReprojection()
%     Wr = M * S;
%     relandmarks = Wr(1:2,:)';
%     
% end
%% exclude the column that point missing accross all the frame
function W = excludeNaNColumn(W,ratio)
% the ratio is a threshold that can 
    checkMat = isnan(W);
    checkMat = ~checkMat;
    missingColIdx = find(sum(checkMat) <= round(size(checkMat,1)*ratio));
    W(:,missingColIdx) = [];
end

%% get the model for procustes analysis
function model = getModelProcus()
% this is the 3D trajectory of the first hand
model = [  241.3138  411.7461    4.8553;
  246.8390  364.0214    4.8553;
  251.1238  323.8973    5.0020;
  254.2609  291.1734    5.1634;
  257.2960  264.1086    5.1963;
  261.1840  244.2217    5.1932;
  266.0222  232.9106    5.1596;
  270.2665  227.9476    5.0799;
  273.4332  226.6102    5.0799;
  274.6103  227.8757    5.0908;
  275.5818  227.6903    5.1246;
  276.9673  225.6182    5.1723;
  278.1354  222.5671    5.1903;
  278.6962  221.1367    5.1895;
  279.2303  220.8401    5.1754;
  279.6436  220.6075    5.1430;
  279.7328  220.7435    5.1699;
  279.4398  219.8342    5.1938;
  279.5573  219.6099    5.1974;
  279.3323  220.0686    5.1749;
  277.5594  221.2085    5.1276;
  276.1691  225.1558    5.1276;
  274.4886  232.3055    5.1276;
  272.1429  241.3898    5.0483;
  268.9703  254.8667    4.9111;
  265.3208  274.1140    4.7432;
  259.7773  299.4872    4.6085;
  251.4480  330.8902    4.5634;
  241.8446  367.4526    4.5646;
  228.4346  405.4651    4.6083];
end