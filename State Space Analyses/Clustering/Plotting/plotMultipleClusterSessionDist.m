function plotMultipleClusterSessionDist(folder,fileStr)
%plotMultipleClusterSessionDist.m Plots the distribution of clusters across
%the session
%
%ASM 10/15

% plotShadedError = true;

%get list of files in folder
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));
nFiles = length(matchFiles);

%loop through each file and create array
allClusterIDs = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    allClusterIDs{fileInd} = currFileData.clusterIDs;
end

%% process
% loop through each
nBins = 4;
whichPlot = 1:10;
thresh = 25;
allClusterDists = [];
pVals = [];
shuffledPVals = [];
for file = 1:nFiles
    clusterIDs = allClusterIDs{file};
    
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
    shuffledPVal = nan(nClusters, 1);
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
            shuffleClusters = shuffleArray(clusterIDs(:,epoch));
            [~,shuffledPVal(ind)] = chi2gof(find(shuffleClusters == uniqueClusters{epoch}(cluster)),...
                'Expected',expectedCounts(ind,:),'edges',edges,'Emin',0);
            
            %increment index
            ind = ind + 1;
        end
    end
    
    %store 
    allClusterDists = cat(1, allClusterDists, clusterDists);
    pVals = cat(1, pVals, pVal);
    shuffledPVals = cat(1, shuffledPVals, shuffledPVal);
    
    
end

allClusterDists = bsxfun(@rdivide, allClusterDists, sum(allClusterDists,2));

%% plot distributions 
figH = figure;
% axDists = subplot(1, 2, 1);
axDists = axes;

plot(allClusterDists');
beautifyPlot(figH,axDists);

axDists.XLabel.String = 'Session quartile';
axDists.YLabel.String = 'Fraction of trials';
axDists.XTick = 1:nBins;

fprintf('Fraction of p values < 0.05: %.2f \n',sum(pVals < 0.05)/length(pVals));

% axPVals = subplot(1, 2, 2);
% hold(axPVals,'on');
% nPBins = 20;
% edges = linspace(0, 1, nPBins+1);
% histReal = histoutline(pVals,edges,false,'Normalization','probability');
% histShuffle = histoutline(shuffledPVals,edges,false,'Normalization','probability');
% uistack(histReal,'top');
% histReal.LineWidth = 2;
% histShuffle.LineWidth = 2;
% histShuffle.Color = [0.7 0.7 0.7];
% legend([histReal,histShuffle],{'Real','Shuffled'},'Location','NorthEast');
% 
% beautifyPlot(figH,axPVals);
% axPVals.XLabel.String = 'P value';
% axPVals.YLabel.String = 'Fraction of clusters';
