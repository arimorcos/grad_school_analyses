function plotClusteredTrajIntraHistoryHistogram(dataCell,clusterIDs)
%plotClusteredTrajIntraHistoryHistogram.m Plots histograms for the
%clustered trajectories for LRL vs. RLL and for RLR vs. LRR
%
%INPUTS
%dataCell - dataCell used for clustering
%clusterIDs - nTrials x 1 array of cluster IDs at segment 3 
%
%ASM 4/15

%argument check 
if size(clusterIDs,2) == 10 
    clusterIDs = clusterIDs(:,4);
end

%convert clusterIDs to 1:nClusters
uniqueClusters = unique(clusterIDs);
nClusters = length(uniqueClusters);
oldClusterIDs = clusterIDs;
for clusterInd = 1:nClusters
    clusterIDs(oldClusterIDs==uniqueClusters(clusterInd)) = clusterInd;
end

%get mazePatterns
mazePatterns = getMazePatterns(dataCell);

%find match trials 
[LRLTrials, RLLTrials, RLRTrials, LRRTrials] = ...
    findHistoryTriplets(mazePatterns,3);

%get matching clusters 
LRLCluster = clusterIDs(LRLTrials);
RLLCluster = clusterIDs(RLLTrials);
LRRCluster = clusterIDs(LRRTrials);
RLRCluster = clusterIDs(RLRTrials);

%get statistics 
pVal = getClusteredTrajIntraHistorySig(dataCell,clusterIDs);

%plot
figH = figure;
faceAlpha = 0.4;

%plot Left 
axL = subplot(2,1,1);
hold(axL,'on');
histL = gobjects(2,1);
histL(1) = histogram(LRLCluster,'FaceAlpha',faceAlpha,'FaceColor','r');
histL(2) = histogram(RLLCluster,'FaceAlpha',faceAlpha,'FaceColor','b');
legend(histL,{'LRL','RLL'},'Location','Best');
axL.FontSize = 20;
axL.YLabel.String = 'Count';
axL.Title.String = sprintf('Left Trials   pVal <= %.3f',pVal(1));

%plot right
axR = subplot(2,1,2);
hold(axR,'on');
histR = gobjects(2,1);
histR(1) = histogram(LRRCluster,'FaceAlpha',faceAlpha,'FaceColor','r');
histR(2) = histogram(RLRCluster,'FaceAlpha',faceAlpha,'FaceColor','b');
legend(histR,{'LRR','RLR'},'Location','Best');
axR.FontSize = 20;
axR.XLabel.String = 'Cluster Number';
axR.Title.String = sprintf('Right Trials   pVal <= %.3f',pVal(2));
axR.YLabel.String = 'Count';