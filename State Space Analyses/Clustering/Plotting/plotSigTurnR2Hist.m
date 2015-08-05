function plotSigTurnR2Hist(out)
%plotSigTurnR2Hist.m Plots histogram with examples of the significant
%turn R2 values 
%
%INPUTS
%out - output of regressClustBehavior
%
%ASM 7/15

pThresh = 0.005;

%% get significant cluster R2

%get nShuffles
nShuffles = size(out.shuffleCluster.clusterR2,2);

%get percentile for each 
sortedShuffleCluster = sort(out.shuffleCluster.clusterR2,2);

%find first greater than 
fracGreaterClusterR2ClusterShuffle = nan(length(out.clusterR2),1);
for neuron = 1:length(out.clusterR2)
    firstGreater = find(out.clusterR2(neuron) >= sortedShuffleCluster(neuron,:),1,'last');
    if ~isempty(firstGreater)
        fracGreaterClusterR2ClusterShuffle(neuron) = firstGreater/nShuffles;    
    else
        fracGreaterClusterR2ClusterShuffle(neuron) = 0;
    end
end

%convert to pValue 
pValCluster = 1 - fracGreaterClusterR2ClusterShuffle;

%% get turn pVal
%get percentile for each 
sortedShuffleTurn = sort(out.shuffleTurn.turnR2,2);

%find first greater than 
fracGreaterTurnR2TurnShuffle = nan(length(out.turnR2),1);
for neuron = 1:length(out.turnR2)
    firstGreater = find(out.turnR2(neuron) >= sortedShuffleTurn(neuron,:),1,'last');
    if ~isempty(firstGreater)
        fracGreaterTurnR2TurnShuffle(neuron) = firstGreater/nShuffles;    
    else
        fracGreaterTurnR2TurnShuffle(neuron) = 0;
    end
end

%convert to pValue 
pValTurn = 1 - fracGreaterTurnR2TurnShuffle;

%get neuron subset which has pValue less than thresh 
keepNeurons = pValTurn <= pThresh;

%% plot 
figH = figure;
axH = axes;
hold(axH,'on');
nBins = 40;

%generate bins 
edges = linspace(0, 1, nBins+1);

%plot histogram
histNotSig = histogram(pValCluster(~keepNeurons),edges,'Normalization','Probability');
histSig = histogram(pValCluster(keepNeurons),edges,'Normalization','Probability');

%beautify
beautifyPlot(figH,axH);

%label
axH.XLabel.String = 'Cluster R^{2} P Value';
axH.YLabel.String = 'Probability';

%add legend 
legend([histSig, histNotSig],{'Significant Turn R^{2}',...
    'Not Significant Turn R^{2}'},'Location','NorthEast');

%% add insets 

%get low, middle, and upper neurons 
takePrctiles = [0.1, 50, 99.9];
keepNeurons = keepNeurons & cellfun(@max,out.clusterMeanActivity) > 0.2;
prctileKeepInd = round((takePrctiles/100)*sum(keepNeurons));
prctileKeepInd = max(1,prctileKeepInd);
[~,sortOrder] = sort(pValCluster(keepNeurons));
keepInd = find(keepNeurons);
sortedKeepInd = keepInd(sortOrder);
% prctileKeepInd = [1, 34, 63];
% prctileKeepInd = 57:60;
prctileNeuronInd = sortedKeepInd(prctileKeepInd);

% annRecLow = annotation('rectangle',[0.04 0.74 0.2 0.25]);
% annRecLow.FaceColor = figH.Color;
axLow = axes('Position',[0.05 0.78 0.2 0.2]);
axis(axLow,'square');
axLow.Box = 'on';
plotClusterActivityIndNeuronSortedByLeft(out, prctileNeuronInd(1), figH, axLow);
startLow = [0.22, 0.88];
yInd = find(pValCluster(prctileNeuronInd(1)) > edges, 1, 'last');
if isempty(yInd)
    yInd = 1;
end
[endXLow, endYLow] = axescoord2figurecoord(...
    roundtowardvec(pValCluster(prctileNeuronInd(1)),edges,'floor')  + 0.5*mean(diff(edges)),...
    histSig.Values(yInd) - 0.01, axH);
annLow = annotation('arrow', [startLow(1), endXLow + 0.5*mean(diff(edges))],...
    [startLow(2), endYLow]);
annLow.LineWidth = 2;

axMid = axes('Position',[0.4 0.78 0.2 0.2]);
axis(axMid,'square');
axMid.Box = 'on';
plotClusterActivityIndNeuronSortedByLeft(out, prctileNeuronInd(2), figH, axMid);
startMid = [0.5, 0.73];
yInd = find(pValCluster(prctileNeuronInd(2)) > edges, 1, 'last');
if isempty(yInd)
    yInd = 1;
end
[endXMid, endYMid] = axescoord2figurecoord(...
    roundtowardvec(pValCluster(prctileNeuronInd(2)),edges,'floor')  + 0.5*mean(diff(edges)),...
    histSig.Values(yInd) - 0.01, axH);
annLow = annotation('arrow', [startMid(1), endXMid + 0.5*mean(diff(edges))],...
    [startMid(2), endYMid]);
annLow.LineWidth = 2;

axHigh = axes('Position',[0.75 0.78 0.2 0.2]);
axis(axHigh,'square');
axHigh.Box = 'on';
plotClusterActivityIndNeuronSortedByLeft(out, prctileNeuronInd(3), figH, axHigh);
startHigh = [0.85, 0.73];
yInd = find(pValCluster(prctileNeuronInd(3)) > edges, 1, 'last');
if isempty(yInd)
    yInd = 1;
end
[endXHigh, endYHigh] = axescoord2figurecoord(...
    roundtowardvec(pValCluster(prctileNeuronInd(3)),edges,'floor')  + 0.5*mean(diff(edges)),...
    histSig.Values(yInd) - 0.01, axH);
annLow = annotation('arrow', [startHigh(1), endXHigh + 0.5*mean(diff(edges))],...
    [startHigh(2), endYHigh]);
annLow.LineWidth = 2;
