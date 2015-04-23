function plotClusterMeanNeuronActivity(dataCell,clusterIDs,whichNeurons,whichPoint,cMat)
%plotClusterMeanNeuronActivity.m Plots the mean activity in each cluster
%for the given neuron 
%
%INPUTS
%dataCell - dataCell containing imaging data
%clusterIDs - clusterIDs output by getClusteredMarkovMatrix
%whichNeurosn - array of neurons to plot 
%whichPoint - which maze point to cluster 
%
%ASM 4/15

pointLabels = {'Maze Start','Segment 1','Segment 2','Segment 3','Segment 4',...
    'Segment 5','Segment 6','Early Delay','Late Delay','Turn'};

if nargin < 5 
    cMat = [];
end

%get full traces 
[~,traces] = catBinnedTraces(dataCell);

%zScore traces 
zTraces = zScoreTraces(traces);

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%get unique clusters at point 
uniqueClusters = unique(clusterIDs(:,whichPoint));
nClusters = length(uniqueClusters);

%sort if necessary
if ~isempty(cMat)
    sortBy = 'leftTurn';
    [~,sortOrder] = sort(cMat.(sortBy){whichPoint});
    sortOrder = flipud(sortOrder);
    uniqueClusters = uniqueClusters(sortOrder);
end

%get full trace for each neuron 
meanTraces = nan(length(whichNeurons),length(yPosBins),nClusters);
for clusterInd = 1:nClusters
    
    %get trials which match 
    matchTrials = uniqueClusters(clusterInd) == clusterIDs(:,whichPoint);
    
    %take average 
    meanTraces(:,:,clusterInd) = nanmean(zTraces(whichNeurons,:,matchTrials),3);
    
end

%crop yPosbins 
meanTraces = meanTraces(:,2:end-1,:);
yPosBins = yPosBins(2:end-1);

%% plot 
figH = figure;
figH.Units = 'normalized';
figH.OuterPosition = [0 0 1 1];

%deteremine number of plots
nRows = 3;
nCol = 1;

%point ranges 
pointRanges = [min(yPosBins), 0:80:480, 535, 600, max(yPosBins)];

%get limits 
uniformYLim = [min(meanTraces(:)) max(meanTraces(:))];

%convert yPosBins to cm 
cmScale = .75;
yPosBins = yPosBins*cmScale;

%loop through each subplot 
for clusterInd = 1:nClusters
    axH = subplot(nRows,nCol,clusterInd);
    
    %plot each of the neurons 
    plotH = plot(yPosBins,meanTraces(:,:,clusterInd));
    [plotH.LineWidth] = deal(1.5);
    
    axH.FontSize = 20;
    axH.XLim = [min(yPosBins) max(yPosBins)];
    axH.YLim = uniformYLim;    
    axis(axH,'square');
    
    %add shaded portion for current segment 
%     shadePatch = patch([pointRanges(whichPoint) pointRanges(whichPoint) ...
%         pointRanges(whichPoint+1) pointRanges(whichPoint+1)],...
%         [min(axH.YLim) max(axH.YLim) max(axH.YLim) min(axH.YLim)],[0.6 0.6 0.6]);
%     shadePatch.FaceAlpha = 0.3;
%     shadePatch.LineStyle = 'none';
%     drawnow;
    
    %add label 
    if clusterInd == 1
        regLabel = text(mean(pointRanges(whichPoint:whichPoint+1)),...
            min(axH.YLim)-0.02*range(axH.YLim),...
            pointLabels{whichPoint});
        regLabel.HorizontalAlignment = 'center';
        regLabel.VerticalAlignment = 'top';
        regLabel.FontSize = 20;
    end
    if clusterInd < nClusters
        axH.XTick = [];
    end
    regLabel.Visible = 'off';
    axH.Title.String = sprintf('Cluster %d',clusterInd);
            
end

%label axes
xLab = suplabel('Maze position (cm)','x');
xLab.FontSize = 30;
yLab = suplabel('Mean zScored dF/F','y',[0.44 0.1 0.8 0.8]);
yLab.FontSize = 30;
