function [video_color, video_gray] = videoDir2FrameSeq(videoPath,method,interval)
% read video from video directory input, using MALTAB VideoReader
% videoPath is the directory of the video to be read
% method is 'mmread' or 'VideoReader'. Using 'mmread' can handle more codec
% but less stable than VideoReader. VideoReader known works on mjpeg codec
% but more stable than mmread.
% interval is downsampling interval. For no downsampling, interval=1;
% video_color is a H-W-3-N tensor where first three dimensions
% corresponding to the image dimensions. The forth dimension is the number
% of frames.
% video_gray is a H-W-N tensor which is the RGB2GRAY version of the first
% output.

if strcmp(method,'VideoReader')
    v = VideoReader(videoPath);
    totalFrameNum = get(v,'numberOfFrames');

    outputFrameIdx = 1;
    for frameIdx = 1:interval:totalFrameNum
        img_temp = read(v,frameIdx);
        video_color(:,:,:,outputFrameIdx) = img_temp;
        video_gray(:,:,outputFrameIdx) = rgb2gray(img_temp);
        outputFrameIdx = outputFrameIdx + 1;
    end
    
elseif strcmp(method,'mmread')
    v = mmread(videoPath);
    totalFrameNum = length(v.frames);
    outputFrameIdx = 1;
    for frameIdx = 1:interval:totalFrameNum
        img_temp = v.frames(frameIdx).cdata;
        video_color(:,:,:,outputFrameIdx) = img_temp;
        video_gray(:,:,outputFrameIdx) = rgb2gray(img_temp);
        outputFrameIdx = outputFrameIdx + 1;
    end
end


end