%% show the comparison of the imitation and original video
name = 'Qianli';
interval = 0.08;
% Set up display window
window = figure('KeyPressFcn',@(obj,evt)setappdata(obj,'flag',true));
setappdata(window,'flag',false);
set(window,'Position',[10,10,1400,700]);

i = 1;
% Start main loop
while true
    eval(['imgwithsift_structs_imitat = ',name,'SiftResults_struct_test2{i};']);
    imgwithsift_structs_origin = OriginSiftResults_struct{i};

    for frame_num = 1:1:length(imgwithsift_structs_imitat)
        imgfeature_imitat = imgwithsift_structs_imitat{1,frame_num};
        imgfeature_origin = imgwithsift_structs_origin{1,frame_num};
        
        if ~isempty(imgfeature_imitat) && ~isempty(imgfeature_origin)
            
            % show the hand mask
            subplot_tight(1,2,1);
            try
                if imgfeature_imitat.ExistConv
                    if size(imgfeature_imitat.ellipsemask,2) == 2
                        BW_mask1 = imgfeature_imitat.ellipsemask{1};
                        BW_mask2 = imgfeature_imitat.ellipsemask{2};
                        handmask = bsxfun(@or,BW_mask1,BW_mask2);
                        mask = bsxfun(@and, handmask, imgfeature_imitat.skinmask);
                        mask = imfill(mask,'hole');
                        imshow(repmat(uint8(mask),1,1,3).*imgfeature_imitat.image)
                    elseif size(imgfeature_imitat.ellipsemask) == 1
                        handmask = imgfeature_imitat.ellipsemask{1};
                        mask = bsxfun(@and, handmask, imgfeature_imitat.skinmask);
                        mask = imfill(mask,'hole');
                        imshow(repmat(uint8(mask),1,1,3).*imgfeature_imitat.image)
                    end
                end
            catch
            end
            
            subplot_tight(1,2,2);
            try
                if imgfeature_origin.ExistConv
                    if size(imgfeature_origin.ellipsemask,2) == 2
                        BW_mask1 = imgfeature_origin.ellipsemask{1};
                        BW_mask2 = imgfeature_origin.ellipsemask{2};
                        handmask = bsxfun(@or,BW_mask1,BW_mask2);
                        mask = bsxfun(@and, handmask, imgfeature_origin.skinmask);
                        mask = imfill(mask,'hole');
                        imshow(repmat(uint8(mask),1,1,3).*imgfeature_origin.image)
                    elseif size(imgfeature_origin.ellipsemask) == 1
                        handmask = imgfeature_origin.ellipsemask{1};
                        mask = bsxfun(@and, handmask, imgfeature_origin.skinmask);
                        mask = imfill(mask,'hole');
                        imshow(repmat(uint8(mask),1,1,3).*imgfeature_origin.image)
                    end
                end
            catch
            end
            
            
%             %------------------
%             imgshow = cv.drawKeypoints(imgfeature_imitat.image,imgfeature_imitat.sift_keypoints);
%             subplot_tight(1,2,1);
%             imshow(imgshow)
%             for j = 1:numel(imgfeature_imitat.facebox)
%                 rectangle('Position',imgfeature_imitat.facebox{j},'EdgeColor','g','LineWidth',2);
%             end
%             
%             subplot_tight(1,2,2);
%             imgshow2 = cv.drawKeypoints(imgfeature_origin.image,imgfeature_origin.sift_keypoints);
%             imshow(imgshow2)
%             for j = 1:numel(imgfeature_imitat.facebox)
%                 rectangle('Position',imgfeature_origin.facebox{j},'EdgeColor','g','LineWidth',2);
%             end
%             %---------------------
        end
        pause(interval)
    end
    
    % Terminate if any user input
    flag = getappdata(window,'flag');
    if isempty(flag) || flag 
        i = i + 1;
        setappdata(window,'flag',false);
        if i == 11
            break
        end
    end
    clear flag
    pause(0.1);
end

% Close
close(window);