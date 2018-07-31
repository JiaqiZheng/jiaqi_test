function [ SkinMask ] = DilateThenEroseUFR( SkinMask )
%Dilation and Erosion according to the untill filled rule
%
SE = strel('disk', 2, 4);

%%
NumMorphy = 0;
BWComponent = bwconncomp(SkinMask);
NumComponent = BWComponent.NumObjects;

while NumComponent > 1
    SkinMask = imdilate(SkinMask,SE);
    % imshow(SkinMask)
    BWComponent = bwconncomp(SkinMask);
    NumComponent = BWComponent.NumObjects;
    NumMorphy = NumMorphy+1;
end
S = regionprops(SkinMask,'Solidity');
LastSolidity = S.Solidity;
SolidityDiff = 1;

while SolidityDiff > 0.02 && LastSolidity < 0.8
    SkinMask = imdilate(SkinMask,SE);
    % imshow(SkinMask)
    S = regionprops(SkinMask,'Solidity');
    ThisSolidity = S.Solidity;
    SolidityDiff = ThisSolidity - LastSolidity;
    LastSolidity = ThisSolidity;
    NumMorphy = NumMorphy+1;
end

for NumErosion = 1:1:NumMorphy
    SkinMask = imerode(SkinMask,SE);
end

% imshow(SkinMask)


end

