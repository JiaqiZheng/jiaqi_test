function [centroid_kalman,HTOutlierIdx] = ExcludeHTOutliersInterpolation(centroid_kalman)
% Exclude the outliers in the head and tail of the 2D trajectory and
% interpolate the outlier point remaining. Output the interpolated
% trajectory and the index of the outliers at the head and tail of the
% original trajectory sequence
% the rows of outliers in centroid_kalman should be set to [Nan,NaN]
    OutlierIndex = find(isnan(centroid_kalman(:,1)));
    SignalIndex = find(~isnan(centroid_kalman(:,1)));
    PreserveMinIdx = min(SignalIndex);
    PreserveMaxIdx = max(SignalIndex);

    InterpolationIdx = OutlierIndex(OutlierIndex >= PreserveMinIdx & OutlierIndex <= PreserveMaxIdx);
    HTOutlierIdx = OutlierIndex(OutlierIndex < PreserveMinIdx | OutlierIndex > PreserveMaxIdx);
    vq = interp1(SignalIndex,centroid_kalman(SignalIndex,:),InterpolationIdx,'pchip');
    centroid_kalman(InterpolationIdx,:) = vq;
end
