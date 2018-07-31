function [predict_label] = ClassifyPredict(TestNewFeature,Classifier)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
MeanTarget = Classifier.MeanTarget;
MeanNonTarget = Classifier.MeanNonTarget;
CovTarget = Classifier.CovTarget;
CovNonTarget = Classifier.CovNonTarget;

% MDistTarget = (TestNewFeature - MeanTarget) * CovTarget^-1 * (TestNewFeature - MeanTarget)';
% MDistNonTarget = (TestNewFeature - MeanNonTarget) * CovNonTarget^-1 * (TestNewFeature - MeanNonTarget)';

MDistTarget = diag(bsxfun(@minus,TestNewFeature, MeanTarget) * bsxfun(@minus,TestNewFeature, MeanTarget)');
MDistNonTarget = diag(bsxfun(@minus,TestNewFeature, MeanNonTarget) * bsxfun(@minus,TestNewFeature, MeanNonTarget)');


predict_label = 2*(MDistTarget <= MDistNonTarget) - 1;


end

