function plotSigClusterR2Hist(out)
%plotSigClusterR2Hist.m Plots histogram with examples of the significant
%cluster R2 values 
%
%INPUTS
%out - output of regressClustBehavior
%
%ASM 7/15

pThresh = 0.05;

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

%get neuron subset which has pValue less than thresh 
keepNeurons = pValCluster <= pThresh;

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


%% plot 
figH = figure;
axH = axes;
hold(axH,'on');
nBins = 20;

%plot histogram
histSig = histogram(pValTurn(keepNeurons),nBins,'Normalization','Probability');
histNotSig = histogram(pValTurn(~keepNeurons),nBins,'Normalization','Probability');

%beautify
beautifyPlot(figH,axH);

%label
axH.XLabel.String = 'Turn R^{2} P Value';
axH.YLabel.String = 'Probability';

%add legend 
legend([histSig, histNotSig],{'Significant Cluster R^{2}',...
    'Not Significant Cluster R^{2}'},'Location','NorthEast');