function out =...
    clusterBehavioralDistribution(clusterIDs,variable)
%clusterBehavioralDistribution.m Analyzes the distribution of a given
%behavioral variable across the clusters 
%
%INPUTS
%clusterIDs - nTrials x 1 array of cluster IDs 
%variable - nTrials x 1 binary behavioral variable 
%
%OUTPUTS
%pVal - probability of distribution by chance
%shuffleVarCount - nUniqueClusters x nShuffles array of counts 
%clusterVarCount - nUniqueClusters x 1 array of actual counts 
%uniqueCount - number of trials in each cluster 
%
%ASM 6/15

nShuffles = 1000;

%arg check 
assert(length(clusterIDs) == length(variable),'clusterIDs and variable must be same length');

%get nTrials
nTrials = length(clusterIDs);

%get unique clusters and count 
[uniqueClusters, uniqueCount] = count_unique(clusterIDs);
nUnique = length(uniqueCount);

%get count in each cluster 
clusterVarCount = getClusterCount(clusterIDs,uniqueClusters,variable,nUnique);

%get expected distribution 
totalVarRate = sum(variable)/nTrials;

%get expected counts 
expectedCounts = totalVarRate*uniqueCount;

%get difference 
summedDiff = sum(abs(clusterVarCount - expectedCounts));

%shuffle 
shuffleDiff = nan(nShuffles,1);
shuffleVarCount = nan(nUnique,nShuffles);
for shuffleInd = 1:nShuffles
    shuffleVarCount(:,shuffleInd) = getClusterCount(shuffleArray(clusterIDs),uniqueClusters,variable,nUnique);
    shuffleDiff(shuffleInd) = sum(abs(shuffleVarCount(:,shuffleInd) - expectedCounts));
end

%get pVal
pVal = 1 - find(summedDiff <= sort(shuffleDiff),1,'first')/nShuffles;
if isempty(pVal)
    pVal = 0;
end

%store 
out.pVal = pVal;
out.uniqueCount = uniqueCount;
out.shuffleVarCount = shuffleVarCount;
out.clusterVarCount = clusterVarCount;
out.summedDiff = summedDiff;
out.shuffleDiff = shuffleDiff;
end

function clusterVarCount = getClusterCount(clusterIDs,uniqueClusters,variable,nUnique)
clusterVarCount = nan(nUnique,1);
for cluster = 1:nUnique
    %get match 
    matchTrials = clusterIDs == uniqueClusters(cluster);
    
    %get count
    clusterVarCount(cluster) = sum(variable(matchTrials));
end
end
