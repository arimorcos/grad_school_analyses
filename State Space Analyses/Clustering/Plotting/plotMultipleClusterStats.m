function plotMultipleClusterStats(folder,fileStr)
%plotMultipleClusterStats.m Plots the various clustering statistics 
%
%ASM 10/15

%get list of files in folder
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));
nFiles = length(matchFiles);

%loop through each file and create array
allStats = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    allStats{fileInd} = currFileData.stats;
end

%% create figure 
figH = figure;
nRows = 2;
nCol = 3;

whichZThresh = find(allStats{1}.zThresh >= 0.2 & allStats{1}.zThresh <=0.7);

%% plot the fraction of self-transitions
axSelfTrans = subplot(nRows, nCol, 1);

%get fracSameCluster
fracSameCluster = cellfun(@(x) x.fracSameCluster, allStats, 'UniformOutput',false);
fracSameCluster = cat(2, fracSameCluster{:})';

%take mean and sem
meanFrac = mean(fracSameCluster);
semFrac = calcSEM(fracSameCluster);
nEpochTrans = length(meanFrac);

%plot 
color = lines(1);
fracH = shadedErrorBar(1:nEpochTrans, meanFrac, semFrac);
fracH.mainLine.Color = color;
fracH.patch.FaceColor = color;
fracH.patch.FaceAlpha = 0.3;
fracH.edge(1).Color = color;
fracH.edge(2).Color = color;

%beautify 
beautifyPlot(figH, axSelfTrans);

%label
axSelfTrans.XLabel.String = 'Epoch transition';
axSelfTrans.YLabel.String = 'Frac self-transitions';

%% one cluster vs. many clusters
axOneVsMany = subplot(nRows, nCol, 2);

%get nOneCluster 
% nOneClustering = cellfun(@(x) x.nUniqueOneCluster, allStats);
% nIndClustering = cellfun(@(x) sum(x.nUniqueEachPoint), allStats);
% clustMat = cat(2,nOneClustering,nIndClustering)';
clustRatio = cellfun(@(x) x.relNClustersIndOne, allStats);

%plot 
% oneIndH = plot([1 2],clustMat);
oneIndH = errorbar(1,mean(clustRatio),calcSEM(clustRatio));
oneIndH.Marker = 'o';
oneIndH.LineWidth = 2;
oneIndH.MarkerSize = 10;
lineH = line([0 2],[1 1]);
lineH.Color = 'k';
lineH.LineStyle = '--';

%beautify 
beautifyPlot(figH, axOneVsMany);

%label
% axOneVsMany.XTick = [1 2];
% axOneVsMany.XTickLabel = {'One clustering','Separate clustering'};
axOneVsMany.XTick = [];
axOneVsMany.YLim = [0 2];
axOneVsMany.XLim = [0 2];
axOneVsMany.XTickLabelRotation = -45;
axOneVsMany.YLabel.String = '# ind clusters/# one clusters';

%% Number of trials in each cluster
axNTrials = subplot(nRows, nCol, 3);

% get number of trials 
nTrialsEachCluster = cellfun(@(x) x.nTrialsEachCluster, allStats, 'UniformOutput', false);
nTrialsEachCluster = cat(1, nTrialsEachCluster{:});

%plot dist
nBins = 25;
nTrialsDist = histogram(nTrialsEachCluster, nBins,...
    'Normalization','Probability');

%beautify 
beautifyPlot(figH, axNTrials);

%label 
axNTrials.XLabel.String = 'Number of trials';
axNTrials.YLabel.String = 'Fraction of clusters';

%% Number of active neurons in each cluster 
axNActive = subplot(nRows, nCol, 4);

% get number of active 
nActive = cellfun(@(x) x.nActiveCat(whichZThresh,:),allStats,'UniformOutput',false);
nActive = cat(2,nActive{:})';

%convert to cdf 
sortedNActive = sort(nActive);

% plot 
fracClusters = [1:size(nActive,1)]/size(nActive,1);
nTrialsH = plot(sortedNActive, fracClusters);

%beautify 
beautifyPlot(figH, axNActive);

%label 
axNActive.XLabel.String = 'Number of neurons above threshold';
axNActive.YLabel.String = 'Cumulative fraction of clusters';

%legend 
legEnt = cell(length(whichZThresh),1);
for ent = 1:length(whichZThresh)
    legEnt{ent} = sprintf('%.1f',allStats{1}.zThresh(whichZThresh(ent)));
end
legend(nTrialsH, legEnt, 'Location', 'SouthEast');

%% number of clusters across epochs which are active 
axEpochCount = subplot(nRows, nCol, 5);

% get number of active 
nEpochsActive = cellfun(@(x) x.nEpochsActive(:,whichZThresh),allStats,'UniformOutput',false);
nEpochsActive = cat(1,nEpochsActive{:});

%convert to cdf 
sortedNEpochsActive = sort(nEpochsActive);

% plot 
fracNeurons = [1:size(nEpochsActive,1)]/size(nEpochsActive,1);
nTrialsH = plot(sortedNEpochsActive, fracNeurons);

%beautify 
beautifyPlot(figH, axEpochCount);

%label 
axEpochCount.XLabel.String = 'Number of epochs active';
axEpochCount.YLabel.String = 'Cumulative fraction of neurons';

%legend 
legEnt = cell(length(whichZThresh),1);
for ent = 1:length(whichZThresh)
    legEnt{ent} = sprintf('%.1f',allStats{1}.zThresh(whichZThresh(ent)));
end
legend(nTrialsH, legEnt, 'Location', 'SouthEast');


%% frac still together 
axStillTogether = subplot(nRows, nCol, 6);
hold(axStillTogether,'on');

% get number of active 
nStillTogether = cellfun(@(x) x.fracStillTogether(:,whichZThresh),allStats,'UniformOutput',false);
nStillTogether = cat(3,nStillTogether{:});

%take mean and sem 
meanStillTogether = nanmean(nStillTogether, 3);
semStillTogether = calcSEM(nStillTogether, 3);

% plot 
for zThresh = 1:length(whichZThresh)
    plot(-9:9,meanStillTogether(:,zThresh));
end

%beautify 
beautifyPlot(figH, axStillTogether);

%label 
axStillTogether.XTick = -8:2:8;
axStillTogether.XLabel.String = '\Delta maze epochs';
axStillTogether.YLabel.String = 'Fraction of coactive neurons still coactive';
legend(legEnt, 'Location', 'Best');

%% number of neurons active in one epoch 
figH = figure;
% axWithinEpochCount = subplot(nRows, nCol, 7);
axWithinEpochCount = axes;

% get number of active
nClustersActive = cellfun(@(x) x.nClustersWithinEpochActive(:, :, whichZThresh),...
    allStats,'UniformOutput',false);
nClustersActive = cat(1, nClustersActive{:});
nClustersActive = squeeze(max(nClustersActive, [], 2));

%convert to cdf 
sortedNEpochsActive = sort(nClustersActive);

% plot 
fracNeurons = [1:size(nClustersActive,1)]/size(nClustersActive,1);
nTrialsH = plot(sortedNEpochsActive, fracNeurons);

%beautify 
beautifyPlot(figH, axWithinEpochCount);

%label 
axWithinEpochCount.XLabel.String = 'Number of clusters within an epoch active';
axWithinEpochCount.YLabel.String = 'Cumulative fraction of neurons';

%legend 
legEnt = cell(length(whichZThresh),1);
for ent = 1:length(whichZThresh)
    legEnt{ent} = sprintf('%.1f',allStats{1}.zThresh(whichZThresh(ent)));
end
legend(nTrialsH, legEnt, 'Location', 'SouthEast');
