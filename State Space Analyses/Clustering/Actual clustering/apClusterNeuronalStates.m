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

%remove all zero traces 
traces = traces';
zeroInd = sum(traces) == 0;
traces = traces(:,~zeroInd);

%create distance matrix
% distMat = -1*squareform(pdist(traces,'cosine'));
% distMat = -1*squareform(pdist(traces,'euclidean'));
blendFac = 0.5;
distMat = -1*((1-blendFac)*squareform(pdist(traces,'cosine')) + ...
    blendFac*squareform(pdist(traces,'euclidean')));

%run apcluster
clusterIDs = apcluster(distMat,prctile(distMat(:),prct),varargin);
