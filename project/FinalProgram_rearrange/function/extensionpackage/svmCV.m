function [ output ] = svmCV( CVtrainData, CVtrainLabel, CVvalidData, CVvalidLabel,paraSVM )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

%% training
% paraSVM = '-s 0 -t 0 -c 1000';
cvSVM = libsvmtrain(CVtrainLabel,CVtrainData,paraSVM);

w  = (full(cvSVM.SVs)' * cvSVM.sv_coef);
b = -cvSVM.rho;
if (cvSVM.Label(1) == -1)
    w = -w; b = -b;
end

%% validation
[predictLabel, accuracy, dec_values] = libsvmpredict(CVvalidLabel, CVvalidData, cvSVM);
%     predictLabel = zeros(size(TestLabel));
%% output
Accuracy = mean(predictLabel == CVvalidLabel);
PerformSVM = confusionmatStats(double(CVvalidLabel),double(predictLabel));

output.numSVs = cvSVM.totalSV;
output.w = w;
output.b = b;
output.accuracy = Accuracy;
output.confuseStats = PerformSVM;

end

