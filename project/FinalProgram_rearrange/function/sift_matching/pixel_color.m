image = video_color(:,:,:,20);
H = size(image,1);
W = size(image,2);

for i = 1:1:H
    for j = 1:1:W
        [xi, yi, P] = impixel(image,i,j);
        
    end
end
