function [boxes] = facedetector(im,plot)
% if want to plot the face detection box with the image

% Load cascade file
xml_file = fullfile(mexopencv.root(),'test','haarcascade_frontalface_alt2.xml');
classifier = cv.CascadeClassifier(xml_file);

% preprocess an image
if length(size(im)) > 2
    im_gray = rgb2gray(im);
end
gr = adapthisteq(im_gray);
% Detect
boxes = classifier.detect(gr,'ScaleFactor',1.3,...
                             'MinNeighbors',2,...
                             'MinSize',[30,30]);
% Draw results
if plot
    imshow(im);
    for i = 1:numel(boxes)
        rectangle('Position',boxes{i},'EdgeColor','g','LineWidth',2);
        drawnow;
    end
end

end

