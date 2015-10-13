function plotClusterHistograms(clusterIDs, whichPlot, thresh)
%plotClusteHistograms.m Plots histograms of clusters across the session.
%Excludes clusters with fewer than thresh trials.
%
%INPUTS
%clusterIDs - nTrials x nEpochs array of clusterIDs
%whichPlot - which clusters to include. Default is all.
%thresh - trial threshold. Default is 20.
%
%ASM 6/15

nBins = 4;

if nargin < 3 || isempty(thresh)
    thresh = 25;
end
if nargin < 2 || iesmpty(whichPlot)
    whichPlot = 1:size(clusterIDs,2);
end

%crop to whichPlot
clusterIDs = clusterIDs(:,whichPlot);

%get nEpochs
[nTrials,nEpochs] = size(clusterIDs);

%get cluster counts at each point
uniqueClusters = cell(nEpochs,1);
uniqueCounts = cell(nEpochs,1);
for epoch = 1:nEpochs
    %get unique clusters and counts
    [tempClusters,uniqueCounts{epoch}] = count_unique(clusterIDs(:,epoch));
    
    %filter
    keepClusters = uniqueCounts{epoch} >= thresh;
    uniqueClusters{epoch} = tempClusters(keepClusters);
    uniqueCounts{epoch} = uniqueCounts{epoch}(keepClusters);
end

%get distributions 
nClusters = sum(cellfun(@length,uniqueClusters));
clusterDists = nan(nClusters,nBins);
expectedCounts = nan(nClusters,nBins);
absCounts = nan(nClusters,nBins);
pVal = nan(nClusters,1);
ind = 1;
edges = linspace(1,nTrials,nBins+1);
for epoch = 1:nEpochs 
    if length(uniqueClusters{epoch}) < 2 
        continue;
    end
    totalEpochCounts = histcounts(find(ismember(clusterIDs(:,epoch),uniqueClusters{epoch})),edges);
    for cluster = 1:length(uniqueClusters{epoch})
        %get counts for individual cluster
        absCounts(ind,:) = histcounts(find(clusterIDs(:,epoch) == uniqueClusters{epoch}(cluster)),edges);
        
        %get expectedCounts 
        expectedCounts(ind,:) = repmat(uniqueCounts{epoch}(cluster)/nBins,1,nBins);
        
        %normalize by total counts
        normEpoch = (totalEpochCounts/sum(totalEpochCounts));
%         clusterDists(ind,:) = absCounts(ind,:)./totalEpochCounts;
        clusterDists(ind,:) = mean(normEpoch)*absCounts(ind,:)./normEpoch;
        expectedCounts(ind,:) = uniqueCounts{epoch}(cluster).*normEpoch;
        
        [~,pVal(ind)] = chi2gof(find(clusterIDs(:,epoch) == uniqueClusters{epoch}(cluster)),...
            'Expected',expectedCounts(ind,:),'edges',edges,'Emin',0);
        
        %increment index
        ind = ind + 1;
    end
end

%% plot 
figH = figure;
ax1 = subplot(1,2,1);

plot(clusterDists');
beautifyPlot(figH,ax1);

ax1.XLabel.String = 'Session Quartile';
ax1.YLabel.String = 'Normalized Count';
ax1.XTick = 1:nBins;

ax2 = subplot(1,2,2);
imagescnan(1:nBins,1:ind-1,clusterDists(1:ind-1,:));
cBar = colorbar;
cBar.Label.String = 'Normalized Count';
beautifyPlot(figH,ax2);
ax2.XLabel.String = 'Session Quartile';
ax2.YLabel.String = 'Cluster #';
ax2.XTick = 1:nBins;
for val = 1:ind-1
    if pVal(val) < 0.05
        textH = text(nBins,val,'*');
        textH.HorizontalAlignment = 'center';
        textH.VerticalAlignment = 'middle';
        textH.FontSize = 20;
        textH.Color = 'k';
    end
end
