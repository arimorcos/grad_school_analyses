function stats = getClusterStats(dataCell,varargin)
%getClusterStats.m Extracts cluster statistics, including number of neurons
%active in each cluster, total number of clusters, number of trials in each
%cluster, number of clusters across epochs each neuron is active in,
%relative number of clusters in one clustering vs. individual clusters, and
%the pairwise intra/inter cluster correlation 
%
%INPUTS
%dataCell - dataCell containing imaging data 
%
%OPTIONAL INPUTS
%   traceType - which trace to use
%   zThresh - array of z thresholds to use 
%
%OUTPUTS
%stats - structure containing cluster statistics
%
%ASM 8/15

traceType = 'deconv';
zThresh = [0 0.5 1];
range = [0.5 0.75];
perc = 10;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'tracetype'
                traceType = varargin{argInd+1};
            case 'zthresh'
                zThresh = varargin{argInd+1};
            case 'range'
                range = varargin{argInd+1};
            case 'perc'
                perc = varargin{argInd+1};
        end
    end
end

nPoints = 10;

[~,cMat,clusterIDs,~] = getClusteredMarkovMatrix(dataCell,...
    'perc',perc,'range',range,'tracetype',traceType);

%get number of clusters 
nUniqueInd = nan(nPoints,1);
for point = 1:nPoints
    nUniqueInd = length(unique(clusterIDs(:,point)));
end

%get number of neurons active in each cluster
actNeurons = cell(length(zThresh),1);
% nActive = 
[clustTraces,~,clustCounts] = getClusteredNeuronalActivity(dataCell,...
    clusterIDs,cMat,'shouldShuffle',false);
for threshInd = 1:length(zThresh)

end

%store 
stats.zThresh = zThresh;
stats.nUniqueClustersInd = nUniqueInd;