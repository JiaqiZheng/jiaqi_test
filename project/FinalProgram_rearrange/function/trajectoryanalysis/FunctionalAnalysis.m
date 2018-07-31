
function [XYZtrajectoryIDCT,CoefficientVector] = FunctionalAnalysis(XYZtransformed_struct,numBasis,show)
% for analyze the 3D trajectory in the DCT space.
% XYZtransformed_struct is array of cells whose each cell contains the 3D
% trajectory of the movement of the center of the hand
for ModelIdx = 1:1:size(XYZtransformed_struct,2)
    for subIdx = 1:1:size(XYZtransformed_struct,1)
        XYZtrajectory = XYZtransformed_struct{subIdx,ModelIdx};
        if size(XYZtrajectory,1) < numBasis
            padsize = [numBasis - size(XYZtrajectory,1), 0];
            XYZtrajectory = padarray(XYZtrajectory, padsize, 'post');
        end
        Xtrajectory = XYZtrajectory(:,1);
        Ytrajectory = XYZtrajectory(:,2);
        Ztrajectory = XYZtrajectory(:,3);
        X_dct = dct(Xtrajectory);
        Y_dct = dct(Ytrajectory);
        Z_dct = dct(Ztrajectory);

        % preserve the low frequency
        X_dct(numBasis+1:end) = 0;
        Y_dct(numBasis+1:end) = 0;
        Z_dct(numBasis+1:end) = 0;

        X_inv = idct(X_dct);
        Y_inv = idct(Y_dct);
        Z_inv = idct(Z_dct);

        if show
%             subplot(3,5,subIdx)
            figure(11)
            plot3(X_inv,Y_inv,Z_inv,'r-','LineWidth',0.75)
            hold on;
%             plot3(XYZtrajectory(:,1),XYZtrajectory(:,2),XYZtrajectory(:,3),'b-');
            grid on;
        end

        X_dct(numBasis+1:end) = [];
        Y_dct(numBasis+1:end) = [];
        Z_dct(numBasis+1:end) = [];

        CoefficientVector(subIdx,:,ModelIdx) = [X_dct;Y_dct;Z_dct];
        XYZtrajectoryIDCT{subIdx,ModelIdx} = [X_inv,Y_inv,Z_inv];
    end
end

end

