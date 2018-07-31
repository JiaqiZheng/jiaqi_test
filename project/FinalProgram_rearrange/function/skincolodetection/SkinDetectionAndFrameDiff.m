function [ imagemat_bw ] = SkinDetectionAndFrameDiff( video_color,video_gray, video_bw_skin, threshFD, show )
% Get skin & motion mask based on color detection and frame difference 

imagemat_bw = false(size(video_gray,1),size(video_gray,2),size(video_gray,3));

numFrames = size(video_color,4);
for frameIdx = 1:1:numFrames  
    %% motion strength based on frame difference
    thisFrameG = video_gray(:,:,frameIdx);
    image_bw_skin = video_bw_skin(:,:,frameIdx);
    
    if frameIdx == 1
        lastFrame = thisFrameG; %zeros(size(thisFrameG)); % notice that this will make the first mask negative for all the pixels
    end
    
    image_bw = FrameDiff( thisFrameG, lastFrame, threshFD);
    [ image_bw ] = PostProcessBinaryMask( image_bw, 4 );
    image_bw = DilateThenErosion(image_bw);
    
    lastFrame = thisFrameG;
    
    image_bw_final = image_bw_skin & image_bw;
    imagemat_bw(:,:,frameIdx) = image_bw_final;

end

if show
    figure;
    for frameIdx = 1:1:size(video_color,4)
        imshow(imagemat_bw(:,:,frameIdx));
        pause(0.3);
    end
end

end

