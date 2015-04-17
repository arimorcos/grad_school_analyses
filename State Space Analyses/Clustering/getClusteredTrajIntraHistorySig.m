function pVal = getClusteredTrajIntraHistorySig(dataCell,clusterIDs,nShuffles)
%getClusteredTrajIntraHistorySig.m Grabs significance for the
%clustered trajectories for LRL vs. RLL and for RLR vs. LRR
%
%INPUTS
%dataCell - dataCell used for clustering
%clusterIDs - nTrials x 10 array of cluster IDs
%nShuffles - number of shuffles. Default is 10000;
%
%OUTPUTS
%pVal - 2 x 1 array of pValues for Left and Right Trials
%
%ASM 4/15

%argument check
if nargin < 3 || isempty(nShuffles)
    nShuffles = 5000;
end

%initialize
totalNClusters = 0;
LRLCluster = [];
RLLCluster = [];
RLRCluster = [];
LRRCluster = [];
clusterStarts = ones(5,1);

%loop through each segment 
for segNum = 3:6
    
    %get tempClusterIDs
    tempClusterIDs = clusterIDs(:,segNum+1);
    
    %convert clusterIDs to 1:nClusters
    uniqueClusters = unique(tempClusterIDs);
    nClusters = length(uniqueClusters);
    oldClusterIDs = tempClusterIDs;
    for clusterInd = 1:nClusters
        tempClusterIDs(oldClusterIDs==uniqueClusters(clusterInd)) = ...
            clusterInd + totalNClusters;
    end
    totalNClusters = totalNClusters + nClusters;
    clusterStarts(segNum-1) = totalNClusters + 1;
    
    %get mazePatterns
    mazePatterns = getMazePatterns(dataCell);
    
    %find match trials
    [LRLTrials, RLLTrials, RLRTrials, LRRTrials] = ...
        findHistoryPairs(mazePatterns,segNum);
    
    %ensure equivalent additions from each size 
%     nLRL = length(LRLTrials);
%     nRLL = length(RLLTrials);
%     if nLRL > nRLL
%         LRLTrials = randsample(LRLTrials,nRLL);
%     elseif nRLL > nLRL 
%         RLLTrials = randsample(RLLTrials,nLRL);
%     end
%     nLRR = length(LRRTrials);
%     nRLR = length(RLRTrials);
%     if nLRR > nRLR
%         LRRTrials = randsample(LRRTrials,nRLR);
%     elseif nRLR > nLRR
%         RLRTrials = randsample(RLRTrials,nLRR);
%     end
    
    %get matching clusters
    LRLCluster = cat(1,LRLCluster,tempClusterIDs(LRLTrials));
    RLLCluster = cat(1,RLLCluster,tempClusterIDs(RLLTrials));
    LRRCluster = cat(1,LRRCluster,tempClusterIDs(LRRTrials));
    RLRCluster = cat(1,RLRCluster,tempClusterIDs(RLRTrials));
   
end

%get real delta count
deltaCountL = getDeltaCount(LRLCluster,RLLCluster,totalNClusters);
deltaCountR = getDeltaCount(LRRCluster,RLRCluster,totalNClusters);
fprintf('L: %d    .... R: %d\n',deltaCountL, deltaCountR);

%concatenate 
allLClusters = sort(cat(1,LRLCluster,RLLCluster));
allRClusters = sort(cat(1,RLRCluster,LRRCluster));

%count
nRL = nan(4,1);
nRR = nan(4,1);
for segNum = 3:6
    nRL(segNum-2) = sum(LRLCluster >= clusterStarts(segNum-2) &...
        LRLCluster < clusterStarts(segNum-1));
    nRR(segNum-2) = sum(LRRCluster >= clusterStarts(segNum-2) &...
        LRRCluster < clusterStarts(segNum-1));
end

%perform shuffle
shuffleCountL = nan(nShuffles,1);
shuffleCountR = nan(nShuffles,1);
for shuffleInd = 1:nShuffles
    
    %extract new clusters
%     tempLClusters = sort(allLClusters);
%     tempRClusters = s(allRClusters);
    tempLR = [];
    tempRR = [];
    tempLL = [];
    tempRL = [];
    
    %create tempClusters segWise
    for segInd = 3:6
        currLClusters = shuffleArray(allLClusters(allLClusters >= clusterStarts(segInd-2) &...
            allLClusters < clusterStarts(segInd-1)));
        currRClusters = shuffleArray(allRClusters(allRClusters >= clusterStarts(segInd-2) &...
            allRClusters < clusterStarts(segInd-1)));
        tempRL = cat(1,tempRL,currLClusters(1:nRL(segInd-2)));
        tempLL = cat(1,tempLL,currLClusters(nRL(segInd-2)+1:end));
        tempRR = cat(1,tempRR,currRClusters(1:nRR(segInd-2)));
        tempLR = cat(1,tempLR,currRClusters(nRR(segInd-2)+1:end));
    end
    
    shuffleCountL(shuffleInd) = getDeltaCount(tempRL,...
        tempLL,totalNClusters);
    shuffleCountR(shuffleInd) = getDeltaCount(tempRR,...
        tempLR,totalNClusters);
    
    %display progress
    dispProgress('Shuffling clusters %d/%d',shuffleInd,shuffleInd,nShuffles);
end

%get pValues
pVal(1) = 1 - find(deltaCountL > sort(shuffleCountL),1,'last')/nShuffles;
pVal(2) = 1 - find(deltaCountR > sort(shuffleCountR),1,'last')/nShuffles;

%plot 
figH = figure;
faceAlpha = 0.4;
binEdges = 0.5:1:totalNClusters-0.5;


%plot Left 
axL = subplot(2,1,1);
hold(axL,'on');
histL = gobjects(2,1);
histL(1) = histogram(LRLCluster,binEdges,...
    'FaceAlpha',faceAlpha,'FaceColor','r');
histL(2) = histogram(RLLCluster,binEdges,...
    'FaceAlpha',faceAlpha,'FaceColor','b');
legend(histL,{'RL','LL'},'Location','EastOutside');
axL.FontSize = 20;
axL.YLabel.String = 'Count';
axL.Title.String = sprintf('Left Trials   pVal <= %.3f',pVal(1));
maxCount = axL.YLim(2);
for segNum = 3:6
    addBracket([clusterStarts(segNum-2) clusterStarts(segNum-1)-1]+0.5,...
        maxCount + 1,sprintf('Segment %d',segNum));
end

%plot right
axR = subplot(2,1,2);
hold(axR,'on');
histR = gobjects(2,1);
histR(1) = histogram(LRRCluster,binEdges,...
    'FaceAlpha',faceAlpha,'FaceColor','r');
histR(2) = histogram(RLRCluster,binEdges,...
    'FaceAlpha',faceAlpha,'FaceColor','b');
legend(histR,{'RR','LR'},'Location','EastOutside');
axR.FontSize = 20;
axR.XLabel.String = 'Cluster Number';
axR.Title.String = sprintf('Right Trials   pVal <= %.3f',pVal(2));
axR.YLabel.String = 'Count';
maxCount = axR.YLim(2);
for segNum = 3:6
    addBracket([clusterStarts(segNum-2) clusterStarts(segNum-1)-1]+0.5,...
        maxCount + 1,sprintf('Segment %d',segNum));
end
end

function deltaCount = getDeltaCount(clusters1,clusters2,nClusters)

%count each
[clust1Val, clust1Count] = count_unique(clusters1);
[clust2Val, clust2Count] = count_unique(clusters2);

%initialize
clust1Dist = zeros(nClusters,1);
clust2Dist = zeros(nClusters,1);

%store counts
clust1Dist(clust1Val) = clust1Count;
clust2Dist(clust2Val) = clust2Count;

deltaCount = sum(abs(clust1Dist-clust2Dist));
end