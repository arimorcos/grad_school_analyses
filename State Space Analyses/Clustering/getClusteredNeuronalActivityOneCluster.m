function [clustTraces,trialTraces,clustCounts] = ...
    getClusteredNeuronalActivityOneCluster(dataCell,clusterIDs,cMat,varargin)
%getClusteredNeuronalActivityOneCluster.m Gets the average z-scored activity of each neuron
%in each cluster for single clustering
%
%INPUTS
%dataCell
%clusterIDs - clusterIDs output by getClusteredMarkovMatrix
%cMat - CMat output by getClusteredMarkovMatrix
%
%OUTPUTS
%clustTraces - nPoints x 1 cell array each containing a matrix of nNeurons
%   x nClusters
%
%ASM 4/15

assert(strcmpi(cMat.mode,'one'),'Must use one clustering paradigm.');

sortBy = 'leftTurn';
shouldShuffle = false;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'sortby'
                sortBy = varargin{argInd+1};
            case 'shouldshuffle'
                shouldShuffle = varargin{argInd+1};
        end
    end
end

%get traces
[~,traces] = catBinnedTraces(dataCell);

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%zScore traces
zTraces = zScoreTraces(traces);

%get maze points
mazePoints = getMazePoints(zTraces,yPosBins);

%get nPoints
[nNeurons,nPoints,~] = size(mazePoints);

%get total uniqueclusters
allClusterIDs = clusterIDs(:);
uniqueClustersAll = unique(allClusterIDs);
nUniqueAll = length(uniqueClustersAll);
uniqueClusters = arrayfun(@(x) unique(clusterIDs(:,x)),1:nPoints,'UniformOutput',false);
nUnique = cellfun(@length,uniqueClusters);

%shuffle cluster
if shouldShuffle
    for point = 1:nPoints
        clusterIDs(:,point) = shuffleArray(clusterIDs(:,point));
    end
end

%get cluster sort order
if ~strcmpi(sortBy,'none') && ~isempty(cMat)
    [~,sortOrder] = sort(nanmean(cat(2,cMat.(sortBy){:}),2));
    sortOrder = flipud(sortOrder);
else
end

%get mean traces
clustTraces = nan(nNeurons,nUniqueAll);
trialTraces = cell(nUniqueAll,1);
clustCounts = cell(nUniqueAll,1);
reshapePoints = reshape(mazePoints,nNeurons,[]);
for cluster = 1:nUniqueAll
    
    %get keepInd
    keepInd = reshape(clusterIDs',1,[]) == uniqueClustersAll(cluster);
    
    %get trial traces
    trialTraces{cluster} = reshapePoints(:,keepInd);
    
    %take mean
    clustTraces(:,cluster) = mean(reshapePoints(:,keepInd),2);
end

%sort 
clustTraces = clustTraces(:,sortOrder);



