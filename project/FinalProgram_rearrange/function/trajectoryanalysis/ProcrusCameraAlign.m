function [ XYZpostTrans,D ] = ProcrusCameraAlign( model1, newXYZ )
% In the camera alignment scenario, eliminate the translation between the
% model and test trajectory, and do reflection if necessary. 

ModelMean = mean(model1);
TestMean = mean(newXYZ);

% define the possible reflection, do centering before reflection
ReflectMatrix = diag([-1,1,1]);
PostReflectTest = ReflectMatrix * bsxfun(@minus,newXYZ, TestMean)';
PostReflectTest = PostReflectTest';
CenterTest = bsxfun(@minus,newXYZ, TestMean);
CenterModel = bsxfun(@minus,model1, ModelMean);

distNoReflect = sum(sqrt(diag((CenterModel - CenterTest) * (CenterModel - CenterTest)')));
distWiReflect = sum(sqrt(diag((CenterModel - PostReflectTest) * (CenterModel - PostReflectTest)')));
% if the distance after reflection is larger than without reflection, then
% do not use reflection.
if distWiReflect < distNoReflect
    XYZpostTrans = bsxfun(@plus, PostReflectTest, ModelMean);
    D = distNoReflect/sum(sum((newXYZ-repmat(mean(newXYZ,1),size(newXYZ,1),1)).^2,1));
else
    XYZpostTrans = bsxfun(@plus, CenterTest, ModelMean);
    D = distWiReflect/sum(sum((newXYZ-repmat(mean(newXYZ,1),size(newXYZ,1),1)).^2,1));
end

end

