function clusterIDs = apClusterNeuronalStates(traces,varargin)
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

%create distance matrix 
distMat = -1*squareform(pdist(traces'));

%run apcluster
clusterIDs = apcluster(distMat,prctile(distMat(:),10),varargin);
% clusterIDs = apcluster(distMat,median(distMat(:)),varargin);