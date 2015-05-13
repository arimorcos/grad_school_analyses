function plotInternalVariability(meanDiffProb,sigMat,acc)
%plotInternalVariability.m Plots the output of quantifyInternalVariability

pointLabels = {'Maze Start','Segment 1','Segment 2','Segment 3','Segment 4',...
    'Segment 5','Segment 6','Early Delay','Late Delay','Turn'};

if size(meanDiffProb,3) > 1 
    meanDiffProb = mean(meanDiffProb,3);
end

if nargin < 3 || isempty(acc)
    acc = false;
end

%get nPoints
nPoints = length(meanDiffProb);

figH = figure;
axH = axes;

%plot image
imagescnan(1:nPoints,1:nPoints,meanDiffProb);

% hold(axH,'on');
%add significance
for rowInd = 1:nPoints
    for colInd = 1:nPoints
        
        switch sigMat(rowInd,colInd)
            case 1
                sigH = text(colInd,rowInd+0.075,'*');
            case 2
                sigH = text(colInd,rowInd+0.075,'**');
            case 3
                sigH = text(colInd,rowInd+0.075,'***');
                
        end
        sigH.Color = 'k';
        sigH.FontSize = 30;
        sigH.HorizontalAlignment = 'Center';
        sigH.VerticalAlignment = 'Middle';
        
    end
end

%label axes
axH.XTick = 1:nPoints;
axH.YTick = 1:nPoints;
axH.XTickLabel = pointLabels;
axH.XTickLabelRotation = -45;
axH.YTickLabel = pointLabels;
axH.FontSize = 15;
axH.YLabel.String = 'Starting Cluster';
axH.YLabel.FontSize = 30;
axH.XLabel.String = 'Ending Cluster';
axH.XLabel.FontSize = 30;
if isnan(meanDiffProb(1))
    axH.XLim = [1.51 nPoints+0.5];
    axH.YLim = [0.51 nPoints-0.51];
else
    axH.XLim = [0.51 nPoints+0.5];
    axH.YLim = [0.51 nPoints+0.5];
end
    

%add colorbar
cBar = colorbar;
if acc
    cBar.Label.String = 'Accuracy';
else
    cBar.Label.String = 'Mean absolute difference from null probability';
end
cBar.Label.FontSize = 20;
