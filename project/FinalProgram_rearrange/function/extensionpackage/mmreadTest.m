% test script for the mmread algorithm
[video, audio] = mmread('/eecf/cbcsl/data100/Qianli2/automatic ASL imitation evaluator/automatic ASL imitation evaluator/original sign/01_H_S_3/01_H_S_3.avi');
videoLength = length(video.frames);
for frameIdx = 1:1:videoLength
    frameImage = video.frames(frameIdx).cdata;
    imshow(frameImage);
    pause(0.03);
end
