function clusterIDs = clusterClusteredTrajectories(clusterTraj,prct)
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

if nargin < 2 || isempty(prct)
    prct = 10;
end

%use pdist with hamming distance 
distMat = -1*squareform(pdist(clusterTraj,'hamming'));

%run apcluster
clusterIDs = apcluster(distMat,prctile(distMat(:),prct));

