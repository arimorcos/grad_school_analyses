function clusterIDs = apClusterNeuronalStates(traces,prct,varargin)
%apClusterNeuronalStates.m Wrapper for affinity propagation 
%
%INPUTS
%traces - nNeurons x nTrials array of neuronal traces
%varargin - arguments to be fed into apcluster
%
%OUTPUTS
%clusterIDs - nTrials x 1 array of cluster labels 
%
%ASM 4/15

if nargin < 2 || isempty(prct)
    prct = 10;
end

%create distance matrix 
distMat = -1*squareform(pdist(traces'));

%run apcluster
clusterIDs = apcluster(distMat,prctile(distMat(:),prct),varargin);
