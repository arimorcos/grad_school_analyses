function clusters = clusterFullTrace(dataCell,clusterProb,dsamp)
%clusterFullTrace.m Clusters entire trace unbiased to any behavioral
%variables, including trial structure 
%
%INPUTS
%dataCell - dataCell containing imaging data
%clusterProb - percentile for clustering
%dsamp - downsample factor
%
%OUTPUTS
%clusters - nFrames x 1 array of cluster identities
%
%ASM 4/15
if nargin < 3 || isempty(dsamp)
    dsamp = 4;
end
if nargin < 2 || isempty(clusterProb)
    clusterProb = 10;
end

keepGroups = 1;

%find roiGroups 
roiGroups = dataCell{find(getCellVals(dataCell,'imaging.imData'),1)}.imaging.roiGroups;
keepInd = ismember(roiGroups{1},keepGroups);

%get complete trace
completeTrace = dataCell{1}.imaging.completeDFFTrace(keepInd,:);

%downsample
frameInd = 1:dsamp:size(completeTrace,2);
frameInd = bsxfun(@plus,frameInd',0:dsamp-1);
meanTrace = nan(size(completeTrace,1),size(frameInd,1));
for i = 1:size(meanTrace,2)
    meanTrace(:,i) = nanmean(completeTrace(:,frameInd(i,:)),2);
end

%cluster
clusters = apClusterNeuronalStates(meanTrace,clusterProb);
