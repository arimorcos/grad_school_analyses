function clusterIDs = dbscanClusterNeuronalStates(traces,distThresh,minPts)
%dbscanClusterNeuronalStates.m Wrapper for dbscan
%
%INPUTS
%traces - nNeurons x nTrials array of neuronal traces
%
%OUTPUTS
%clusterIDs - nTrials x 1 array of cluster labels 
%
%ASM 4/15

if nargin < 3 || isempty(minPts)
    minPts = 5;
end
if nargin < 2 || isempty(distThresh)
    distThresh = 5;
end

%run dbscan
[~,clusterIDs,~] = dbscan(traces,distThresh,minPts);