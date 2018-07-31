function VisualizeWeightDCTsamples( testTraj,ProjectW,TargetSign )
%Visualize the testTraj with weight color. The color of each data are from
%the color map corresponding to the ProjectW. ProjectW should be the LDA
%projection(weight) for the TargetSign(the name of target class)

% normalize the projection of the
ProjectWabs = FeatureScalingNormalize(abs(ProjectW),0,1);

X = 1:1:24;
Y = testTraj;

figure;
scatter(X,Y,40,abs(ProjectWabs),'filled');
map = zeros(length(ProjectWabs),3);
map(:,2) = 0+1/length(ProjectWabs):1/length(ProjectWabs):1;
colormap(map)
t = title(['DCT coefficients.',' Target sign ',TargetSign]);
set(t,'Interpreter','none');
xlabel('DCT dimensions')
ylabel('Value of the coefficients');
c = colorbar;
ylabel(c,'Weight in LDA projection')
hold on
yRng = ylim; yMax = yRng(2); yMin = yRng(1);
xRng = xlim;
% patch([0,0,8.5,8.5],[yMax,yMin,yMin,yMax],'red','EdgeColor','none','FaceAlpha',.1)
patch([8.5,8.5,16.5,16.5],[yMax,yMin,yMin,yMax],[0.7,0.7,0.7],'EdgeColor','none','FaceAlpha',.1)
% patch([16.5,16.5,25,25],[yMax,yMin,yMin,yMax],'red','EdgeColor','none','FaceAlpha',.1)
scatter(X,Y,40,abs(ProjectWabs),'filled');
text(4,yMax-100,'x','FontSize',14)
text(12,yMax-100,'y','FontSize',14)
text(20,yMax-100,'z','FontSize',14)


end

