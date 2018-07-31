function faceBBmaskCell = GetFaceSkinPixelNum(skinColorMask,boxes)
% find the skincolor mask within the face bounding boxes.
% faceBBmaskCell contains a image with each pixels contains a bool value
% which indicating whether this pixel belongs to the skin color and inside
% the face bounding box. The size of the faceBBmaskCell is the same as the
% boxes. 
% skinColorMask is a binary mask whose true pixels belong to skin color and
% false belong non-skin color
% boxes is a cell array whose each cell saving a 4-d vector whose first 2
% entries are the x and y coordinates of upper-left of bounding box and
% last two denotes the size of the bounding box (height and width)

faceBBmaskCell = cell(size(boxes));

for faceBBidx = 1:1:length(boxes)
    faceBBmask = false(size(skinColorMask));
    width = boxes{faceBBidx}(3); % only use the width since the bounding boxes are square
    faceBBmask(boxes{faceBBidx}(2):1:boxes{faceBBidx}(2)+width,...
               boxes{faceBBidx}(1):1:boxes{faceBBidx}(1)+width) = true;
    faceBBmaskCell{faceBBidx} = faceBBmask & skinColorMask;
end

end