function [clusterCenters] = getClusterCenters(clusterIDs,tracePoints)
%createTransitionMatrix.m Given a set of cluster ids, grabs the mean
%cluster center for each cluster
%
%INPUTS
%clusterIDs-  nTrials x nPoints array of cluster ids 
%tracePoints - nNeurons x nPoints array of neuronal activity at each maze
%   point
%
%OUTPUTS
%clusterCenters - nPoints x 1 cell array each containing a nNeurons x
%   nClusters array of clusterCenters
%
%ASM 4/15


%% get relevant variables 
nPoints = size(clusterIDs,2);
nNeurons = size(tracePoints,1);


%% get cluster centers
clusterCenters = cell(nPoints,1);
for point = 1:nPoints
    
    %get unique clusters
    uniqueClusters = sort(unique(clusterIDs(:,point)));
    nClusters = length(uniqueClusters);
    
    %initialize
    clusterCenters{point} = nan(nNeurons,nClusters);
    
    for clusterInd = 1:nClusters
        clusterCenters{point}(:,clusterInd) = ...
            mean(tracePoints(:,point,clusterIDs(:,point) == ...
            uniqueClusters(clusterInd)),3);
    end
end