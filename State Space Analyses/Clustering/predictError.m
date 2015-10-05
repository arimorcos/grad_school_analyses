function [handles, errorMat, out] = predictError(dataCell, varargin)
%predictError.m Predicts an error trial using provided maze point
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OPTIONAL INPUTS
%clusterPerc - percentile value for clustering. Default is 30.
%whichPoint - which maze point. Default is 1.
%
%OUTPUTS
%
%ASM 6/15

clusterPerc = 30;
whichPoint = 1;
handles = [];
showNTrials = true;
showPValue = true;
traceType = 'dff';

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'clusterperc'
                clusterPerc = varargin{argInd+1};
            case 'whichpoint'
                whichPoint = varargin{argInd+1};
            case 'handles'
                handles = varargin{argInd+1};
            case 'showntrials'
                showNTrials = varargin{argInd+1};
            case 'showpvalue'
                showPValue = varargin{argInd+1};
            case 'tracetype'
                traceType = varargin{argInd+1};
        end
    end
end

if ~iscell(dataCell{1})
    dataCell = {dataCell};
end

%get nDataCells
nDataCells = length(dataCell);

%initialize
correctTrial = [];
clusterIDs = [];

for dInd = 1:nDataCells
    
    %get yPosBins
    yPosBins = dataCell{dInd}{1}.imaging.yPosBins;
    
    %get traces
    switch lower(traceType)
        case 'dff'
            [~,traces] = catBinnedTraces(dataCell{dInd});
        case 'deconv'
            traces = catBinnedDeconvTraces(dataCell{dInd});
    end
    
    %create matrix of values at each point in the maze
    tracePoints = getMazePoints(traces,yPosBins);
    
    %crop to whichPoint
    tracePoints = squeeze(tracePoints(:,whichPoint,:));
    
    %cluster
    tempClusterIDs = apClusterNeuronalStates(tracePoints,clusterPerc,'maxits',1e4);
    tempClusterIDs = tempClusterIDs + (dInd-1)*1000;
    
    %get correct or incorrect
    tempCorrectTrial = getCellVals(dataCell{dInd},'result.correct==1')';
    
    %cat
    correctTrial = cat(1,correctTrial,tempCorrectTrial);
    clusterIDs = cat(1,clusterIDs,tempClusterIDs);
    
end

%get unique clusters and count
[uniqueClusters, uniqueCount] = count_unique(clusterIDs);

%get error rate in each cluster
errorCount = getErrorCount(correctTrial,uniqueClusters,clusterIDs);
errorRate = errorCount./uniqueCount;

%get expected errors
totalErrorRate = sum(~correctTrial)/length(correctTrial);
expectedErrors = uniqueCount*totalErrorRate;

%get summed difference
summedDiff = sum(abs(errorCount - expectedErrors));

%perform shuffle
nShuffles = 1000;
shuffledSummedDiff = nan(nShuffles,1);
for shuffleInd = 1:nShuffles
    dispProgress('Shuffling %d/%d',shuffleInd,shuffleInd,nShuffles);
    shuffleErrorCount = getErrorCount(correctTrial,uniqueClusters,shuffleArray(clusterIDs));
    shuffledSummedDiff(shuffleInd) = sum(abs(shuffleErrorCount - expectedErrors));
end

%compare to uniform distribution
% correctTrial = shuffleArray(correctTrial);
% errorClusters = clusterIDs(~correctTrial);
%
% edges = cat(1,uniqueClusters-0.5,uniqueClusters(end)+0.5);
% [~,pVal,stats] = chi2gof(errorClusters,...
%             'Expected',expectedErrors,'edges',edges,'Emin',0);

%calculate p value
pVal = 1 - find(summedDiff <= sort(shuffledSummedDiff),1,'first')/nShuffles;
if isempty(pVal)
    pVal = 0;
end

out.realSummedDiff = summedDiff;
out.shuffledSummedDiff = shuffledSummedDiff;
out.totalErrorRate = totalErrorRate;
out.expectedErrors = expectedErrors;
out.errorCount = errorCount;
out.uniqueCount = uniqueCount;

%create errorMat
errorMat = cat(2,errorCount,uniqueCount);
out.errorMat = errorMat;
%% plot
if isempty(handles)
    handles.fig = figure;
    handles.ax = axes;
    hold(handles.ax,'on');
end

%plot sorted error rate
plotH = plot(sort(errorRate));
plotH.Marker = 'o';
plotH.MarkerSize = 12;
plotH.LineWidth = 2.5;
if pVal <= 0.05
    plotH.MarkerFaceColor = plotH.MarkerEdgeColor;
end

%beautify
beautifyPlot(handles.fig,handles.ax);

%label
handles.ax.XLabel.String = 'Sorted Cluster #';
handles.ax.YLabel.String = 'Error Rate';

%add nTrials
if showNTrials
    [sortedError,sortOrder] = sort(errorRate);
    sortCount = uniqueCount(sortOrder);
    for val = 1:length(uniqueCount)
        textH = text(val,sortedError(val)+0.01*range(handles.ax.YLim),num2str(sortCount(val)));
        textH.VerticalAlignment = 'bottom';
        textH.HorizontalAlignment = 'center';
        textH.FontSize = 20;
    end
end

%add pValue
if showPValue
    textH = text(min(handles.ax.XLim)+0.05*range(handles.ax.XLim),...
        max(handles.ax.YLim)-0.05*range(handles.ax.YLim),...
        sprintf('p = %.3f',pVal));
    textH.HorizontalAlignment = 'left';
    textH.VerticalAlignment = 'top';
    textH.FontSize = 20;
end

%store
if isfield(handles,'plotH')
    handles.plotH(length(handles.plotH)+1) = plotH;
else
    handles.plotH = plotH;
end

%change color
nColors = length(handles.plotH);
colors = distinguishable_colors(nColors);
for plotInd = 1:nColors
    handles.plotH(plotInd).MarkerEdgeColor = colors(plotInd,:);
    if pVal <= 0.05
        handles.plotH(plotInd).MarkerFaceColor = colors(plotInd,:);
    end
    handles.plotH(plotInd).Color = colors(plotInd,:);
end
end

function errorCount = getErrorCount(correctTrial,uniqueClusters,clusterIDs)
errorCount = nan(size(uniqueClusters));
for clusterInd = 1:length(uniqueClusters)
    matchTrials = clusterIDs == uniqueClusters(clusterInd);
    errorCount(clusterInd) = sum(~correctTrial(matchTrials));
end
end