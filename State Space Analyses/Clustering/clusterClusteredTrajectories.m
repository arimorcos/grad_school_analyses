function clusterIDs = clusterClusteredTrajectories(clusterTraj,whichPoints,prct)
%clusterClusteredTrajectories.m Clusters trajectories output by
%getClusteredMarkovMatrix.m 
%
%INPUTS
%clusterTraj - clusterIDs output by getClusteredMarkovMatrix
%prct - percentile to use for clustering
%
%OUTPUTS
%clusterIDs - nTrials x 1 array of cluster IDs
%
%ASM 4/15

if nargin < 3 || isempty(prct)
    prct = 10;
end
if nargin < 2 || isempty(whichPoints)
    whichPoints = 1:10;
end

%crop
clusterTraj = clusterTraj(:,whichPoints);

%use pdist with hamming distance 
distMat = -1*squareform(pdist(clusterTraj,'hamming'));

%run apcluster
clusterIDs = apcluster(distMat,prctile(distMat(:),prct),'nonoise');

