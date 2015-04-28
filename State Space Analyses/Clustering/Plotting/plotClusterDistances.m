function plotClusterDistances(clusterCenters,cMat,sortBy,plotPoint)
%plotClusterDistances.m Calculates the distances between clusters and sorts
%by a given variable 
%
%INPUTS
%clusterCenters - nPoints x 1 cell array each containing a nNeurons x
%   nClusters array of clusterCenters
%cMat - structure containing cluster labels for different properties
%sortBy - variable to sort base on
%plotPoint - point to plot
%
%ASM 4/15
pointLabels = {'Maze Start','Segment 1','Segment 2','Segment 3','Segment 4',...
    'Segment 5','Segment 6','Early Delay','Late Delay','Turn'};
nPoints = length(clusterCenters);

%sort points
if ~strcmpi(sortBy,'none') && ~isempty(cMat)
    clusterVals = cell(nPoints,1);
    for point = 1:nPoints
        [clusterVals{point},tempSortOrder] = sort(cMat.(sortBy){point});
        clusterCenters{point} = clusterCenters{point}(:,tempSortOrder);
    end
end

%calculate distance
distMat = squareform(pdist(clusterCenters{plotPoint}'));
nClusters = length(distMat);

%create figure
figH = figure;
axH = axes;

%plot imagesc 
distPlot = imagesc(1:nClusters,1:nClusters,distMat);
axH.XTick = 1:nClusters;
axH.YTick = 1:nClusters;
axH.XTickLabel = clusterVals{plotPoint};
axH.YTickLabel = clusterVals{plotPoint};
axH.XTickLabelRotation = -45;
axH.FontSize = 20;
axH.LabelFontSizeMultiplier = 1.5;

%label 
axH.XLabel.String = sortBy;
axH.YLabel.String = sortBy;
axH.Title.String = pointLabels{plotPoint};
axis(axH,'square');

%add colorbar 
cBar = colorbar;
cBar.Label.String = 'Euclidean distance';
cBar.Label.FontSize = 30;