function [ TotalOutlierIdx ] = eliminatOutliers( X, n_sigma, mode )
%Eliminate the outliers in the column vector X. The outlier is defined as the 
%   mode = 'IterativeGaussian'   iteratively run n-sigma gaussian outlier
%   detection untill no new outliers detected.
%   mode = 'MedianFilter'        run n-MAD outlier detection.
%   n_sigma                      number of std or mad using in outleir detection.
%   the hampel filter is almost the same as the median filter. however,
%   it is directly use the signal and using a sliding window to calculate
%   the median of the signal in the window.

index_origin = 1:1:size(X);
index_after = 1:1:size(X);
x3 = X; % for manually checking if the outlier is correctly chosen
ThisOutlierIdx = 0;
TotalOutlierIdx = [];
% when there is still outliers remove the points out of the 3 sigma
switch  mode
    case 'IterativeGaussian'
        while ~isempty(ThisOutlierIdx) 
            x1 = X;
            x2 = X;
            x1(1,:) = []; % from 2 to end
            x2(end,:) = []; % from 1 to end-1

        %     x1_flip = flipud(X);
        %     x2_flip = flipud(X);
        %     x1_flip(1,:) = []; % from 2 to end
        %     x2_flip(end,:) = []; % from 1 to end-1

            x_diff = sqrt(sum((x1 - x2).^2,2));
        %     x_diff2 = sqrt(sum((x1_flip - x2_flip).^2,2));
            mean_diff = mean(x_diff,'omitnan');
            std_diff = std(x_diff,'omitnan');

            outlier_thresh = mean_diff + n_sigma*std_diff;

            ThisOutlierIdx = find(x_diff>= outlier_thresh)+1;
            X(ThisOutlierIdx,:) = NaN;
            TotalOutlierIdx = [TotalOutlierIdx;ThisOutlierIdx];
            plot(x1(:,1));
        end
    case 'MedianFilter'
        x1 = X;
        x2 = X;
        x1(1,:) = []; % from 2 to end
        x2(end,:) = []; % from 1 to end-1
        x_diff = sqrt(sum((x1 - x2).^2,2));

        % flip the sequence and recalculate the distance to solve the
        % misdetection on the normal point next to the outliers
        x1_flip = flipud(X);
        x2_flip = flipud(X);
        x1_flip(1,:) = []; % from 2 to end
        x2_flip(end,:) = []; % from 1 to end-1
        x_diff_flip = sqrt(sum((x1_flip - x2_flip).^2,2));

        while ~isempty(ThisOutlierIdx)
            med1 = median(x_diff,'omitnan');
            mad1 = median(abs(x_diff - med1),'omitnan');
            outlier_thresh = med1 + n_sigma*mad1;
            outlieridx_natural = find(x_diff>= outlier_thresh);
            x_diff(outlieridx_natural) = med1;
            outlieridx_natural = outlieridx_natural+1;

            med2 = median(x_diff_flip,'omitnan');
            mad2 = median(abs(x_diff_flip - med2),'omitnan');
            outlier_thresh_flip = med2 + n_sigma*mad2;
            outlieridx_flip = find(x_diff_flip>= outlier_thresh_flip);
            x_diff_flip(outlieridx_flip) = med2;
            outlieridx_flip = length(x1_flip) - outlieridx_flip + 1;

            ThisOutlierIdx = intersect(outlieridx_flip,outlieridx_natural);

            X(ThisOutlierIdx,:) = NaN;
            TotalOutlierIdx = [TotalOutlierIdx;ThisOutlierIdx];
            % plot(x1(:,1));
        end
    case 'Hampel'
        X_test = X(:,1);
        Y_test = X(:,2);
        WindowWidth = round(size(X,1) * 0.15);
        while ~isempty(ThisOutlierIdx)
            SequenceTime = 1:1:length(X);
            [X_test,X_Idx] = hampel(SequenceTime,X_test,WindowWidth,n_sigma);
            [Y_test,Y_Idx] = hampel(SequenceTime,Y_test,WindowWidth,n_sigma);
            XoutlierIdx = find(X_Idx);
            YoutlierIdx = find(Y_Idx);
            ThisOutlierIdx = union(XoutlierIdx,YoutlierIdx,'rows');
            TotalOutlierIdx = [TotalOutlierIdx;ThisOutlierIdx];
        end
end

end

