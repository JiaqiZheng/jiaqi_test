function data_cell = getPointCorrespondences(SkinAndEllipse,n)
% get the point correspondences
BadSubjectNum = [];
for SubjectNum = 1:1:length(SkinAndEllipse)
    SamplePFinal_cell = cell(1,length(SkinAndEllipse{SubjectNum}));
    % check if there is any bad frames that correspondences cannot be found
    BadFramesIdx = FindBadFrames(SkinAndEllipse{SubjectNum});
    if isempty(BadFramesIdx)
        % calculate the samples of the first contour
        t = 1/n:1/n:1;
        SkinMaskFirst = SkinAndEllipse{SubjectNum}{1};
        [ SkinMaskFirst ] = DilateThenEroseUFR( SkinMaskFirst );
        Contour1 = bwboundaries(SkinMaskFirst);
        MaxContourIdx = getMaxContour(Contour1);
        P1 = Contour1{MaxContourIdx};
        P1(end,:) = [];
        SamplePprevious = interparc(t,P1(:,1),P1(:,2));
        SamplePFinal_cell{1} = SamplePprevious;

        % find the point correspondences for the following contours
        for i = 2:1:length(SkinAndEllipse{SubjectNum})
            SkinMaskCurrent = SkinAndEllipse{SubjectNum}{i};
            [ SkinMaskCurrent ] = DilateThenEroseUFR( SkinMaskCurrent );
            Contour2 = bwboundaries(SkinMaskCurrent);
            MaxContourIdx = getMaxContour(Contour2);
            P2 = Contour2{MaxContourIdx};
            P2(end,:) = [];

            % find corresponding points 
            [ SamplePFinal ] = fromTwoFrame2Correspondences( SamplePprevious,P2,n );
            SamplePprevious = SamplePFinal;


            SamplePFinal_cell{i} = SamplePFinal;
        end

        %% show the sampled point correspondences
        % imgshow_cell = NewImgfeatureStruct5{SubjectNum};
        % 
        % for frameIdx = 1:1:length(SamplePFinal_cell)
        %     imgshow_hsv = rgb2hsv(imgshow_cell{frameIdx}.image);
        %     imgshow_h = imgshow_hsv(:,:,3);
        %     CorrPoints = SamplePFinal_cell{frameIdx};
        %     imshow(imgshow_h)
        %     hold on
        %     plot(CorrPoints(:,2),CorrPoints(:,1),'r*') 
        %     pause(1)
        % end
        %% change the SamplePFinal to data matrix
        clear sift_cell
        for frameIdx = 1:1:length(SamplePFinal_cell)
            CorrPoints = SamplePFinal_cell{frameIdx};
            CorrPoints = fliplr(CorrPoints);
            sift_mat = mat2cell(CorrPoints,ones(1,length(CorrPoints)),2)';
            sift_cell(frameIdx,:) = sift_mat;
        end
        data_cell{SubjectNum} = sift_cell;
%         disp(['Subject ',num2str(SubjectNum),' is done.'])
    else
        BadSubjectNum = [BadSubjectNum,SubjectNum];
        data_cell{SubjectNum} = [];
%         disp(['Subject ',num2str(SubjectNum),' cannot be processed. The hand in frame ',num2str(BadFramesIdx),' cannot be detected.']);
    end
    
end
% exclude the bad subject
data_cell(BadSubjectNum) = [];
end

function MaxContourIdx = getMaxContour(Contour)
    ContourLength = zeros(size(Contour));
    for ContourIdx = 1:1:length(Contour)
        ContourLength(ContourIdx) = size(Contour{ContourIdx},1);
    end
    MaxContourIdx = find(ContourLength == max(ContourLength));
end

function BadFramesIdx = FindBadFrames(SkinMaskCurrentVideo)
    BadFrames = cellfun(@(V) any(isnan(V(:))),SkinMaskCurrentVideo);
    BadFramesIdx = find(BadFrames);
end
