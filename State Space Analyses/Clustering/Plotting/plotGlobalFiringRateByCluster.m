function plotGlobalFiringRateByCluster(dataCell)
%plotGlobalFiringRateByCluster.m Plots the mean z-scored firing rate for
%each cluster at each time point 
%
%INPUTS
%data - either a dataCell or clustTraces
%
%OUTPUTS
%
%ASM 6/15

pointLabels = {'Maze Start','Segment 1','Segment 2','Segment 3','Segment 4',...
    'Segment 5','Segment 6','Early Delay','Late Delay','Turn'};

%% calculate basics 

%get cluster information
[~,cMat,clusterIDs,~]=getClusteredMarkovMatrix(dataCell);
[clustTraces,~,clustCounts] = getClusteredNeuronalActivity(dataCell,clusterIDs,cMat);

%get mean firing rate at each point
yPosBins = dataCell{1}.imaging.yPosBins;
[~,traces] = catBinnedTraces(dataCell);
tracePoints = getMazePoints(traces,yPosBins);
epochMean = mean(mean(tracePoints,3),1);

%get nEpochs 
nEpochs = length(clustTraces);

%filter out below 5 trials 
trialThresh = 5;
for epoch = 1:nEpochs
    keepInd = clustCounts{epoch} >= trialThresh;
    clustTraces{epoch} = clustTraces{epoch}(:,keepInd);
end

%take mean of each cluster at each time point 
meanVal = cellfun(@mean,clustTraces,'UniformOutput',false);
% semVal = cellfun(@calcSEM,clustTraces,'UniformOutput',false);
nClusters = cellfun(@(x) size(x,2),clustTraces);


%% perform stats
%get summed deviaton from epoch mean 
realSummedDev = getSummedDeviation(meanVal,epochMean);

nShuffles = 200;
shuffledSummedDev = nan(nEpochs,nShuffles);
for shuffleInd = 1:nShuffles 
    dispProgress('Shuffle ind %d/%d',shuffleInd,shuffleInd,nShuffles);
    
    [tempTraces,~,~] = getClusteredNeuronalActivity(dataCell,clusterIDs,...
        cMat,'shouldShuffle',true);
    tempMeanVal = cellfun(@mean,tempTraces,'UniformOutput',false);
    shuffledSummedDev(:,shuffleInd) = getSummedDeviation(tempMeanVal,epochMean);
end

%% plot left plot
%create figure 
figH = figure;
axL = subplot(1,2,1);
hold(axL,'on');

%loop and plot 
colors = distinguishable_colors(nEpochs);
plotH = gobjects(nEpochs,1);
for epoch = 1:nEpochs
    
    %plot 
%     plotH(epoch) = errorbar(1:nClusters(epoch),meanVal{epoch},semVal{epoch});
    plotH(epoch) = plot(1:nClusters(epoch),meanVal{epoch});
    plotH(epoch).Color = colors(epoch,:);
    plotH(epoch).LineWidth = 2;
    
end

%beautify
beautifyPlot(figH,axL);

%label
axL.XLabel.String = 'Cluster #';
axL.YLabel.String = 'Mean z-scored activity';

%add legend 
legH = legend(plotH,pointLabels,'Location','BestOutside');

%% plot right 
axR = subplot(1,2,2);
hold(axR,'on');

%plot error bars 
confInt = prctile(shuffledSummedDev,[0.5 99.5],2);
shuffleMedian = median(shuffledSummedDev,2);
confInt = bsxfun(@minus,confInt,shuffleMedian);
errH = errorbar(1:nEpochs,shuffleMedian,confInt(:,1),confInt(:,2));
errH.Marker = 'none';
errH.LineStyle = 'none';
errH.Color = 'r';

%plot actual 
plotH = scatter(1:nEpochs,realSummedDev,'b','filled');

%beautify
beautifyPlot(figH,axR);

%label
axR.XTick = 1:nEpochs;
axR.XTickLabel = pointLabels;
axR.XTickLabelRotation = -45;
axR.YLabel.String = 'Summed deviation from total mean';

end 

function summedDev = getSummedDeviation(meanVal,epochMean)
summedDev = nan(length(epochMean),1);
for epoch = 1:length(epochMean)
    summedDev(epoch) = sum(abs(meanVal{epoch} - epochMean(epoch)));
end
end