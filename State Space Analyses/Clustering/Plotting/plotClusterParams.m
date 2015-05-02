function plotClusterParams(cMat,param,whichPlot)
%plotClusterParams. Plots histograms of cluster parameters at each point 
%
%INPUTS
%cMat - cMat output by getClusteredMarkovMatrix 
%param - name of parameter to plot
%whichPlot - which plots to show 
%
%ASM 4/15

pointLabels = {'Maze Start','Segment 1','Segment 2','Segment 3','Segment 4',...
    'Segment 5','Segment 6','Early Delay','Late Delay','Turn'};

%nBins 
nBins = 5;

%get nPoints
nPoints = length(cMat.netEv);

if nargin < 3 || isempty(whichPlot)
    whichPlot = 1:10;
end

%get data
if ~isfield(cMat.dPoints,param)
    error('%s is not a field of cMat',param);
end
data = cMat.dPoints.(param);

%create figure
figH = figure;
nPlots = length(whichPlot);
[nRows,nCol] = calcNSubplotRows(nPlots);

%loop through 
for plotInd = 1:nPlots
    axH = subplot(nRows,nCol,plotInd);
    hold(axH,'on');
    
    %get pointData
    pointData = data{whichPlot(plotInd)};
    
    %get minimum value
    minVal = min(cat(2,pointData{:}));
    maxVal = max(cat(2,pointData{:}));
    
    %get edges 
    edges = linspace(minVal,maxVal,nBins+1);
    
    %loop through clusters and get array 
    nClusters = length(pointData);
    clusterCounts = nan(nClusters,nBins);
    for clusterInd = 1:nClusters
        
        %get count 
        clusterCounts(clusterInd,:) = histcounts(pointData{clusterInd},edges);
        
    end
    
    %normalize each by frequency 
    normCounts = bsxfun(@rdivide,clusterCounts,sum(clusterCounts,2));
    
    %plot 
    totalWidth = 10;
    clusterFrac = sum(clusterCounts,2)/sum(clusterCounts(:));
    colors = distinguishable_colors(nClusters);
    for clusterInd = 1:nClusters
        plotH = plot(edges(1:end-1) + diff(edges),normCounts(clusterInd,:));
        plotH.LineWidth = totalWidth*clusterFrac(clusterInd);
        plotH.Color = colors(clusterInd,:);        
    end
    
    %set axis properties 
    axH.XLim = [minVal maxVal];  
    axis(axH,'square');
    axH.Title.String = pointLabels{whichPlot(plotInd)};
end

%add labels 
xLab = suplabel(param,'x');
xLab.FontSize = 30;
yLab = suplabel('Frequency','y');
yLab.FontSize=  30;
