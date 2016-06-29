function [clustTraces,trialTraces,clustCounts] = ...
    getClusteredNeuronalActivity(dataCell,clusterIDs,cMat,varargin)
%getClusteredNeuronalActivity.m Gets the average z-scored activity of each neuron
%in each cluster 
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


sortBy = 'leftTurn';
shouldShuffle = false;
meanSubtract = false;

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
            case 'meansubtract'
                meanSubtract = varargin{argInd+1};
        end
    end
end

%get traces
useDeconv = true;
if useDeconv
    traces = catBinnedDeconvTraces(dataCell);
else 
    [~, traces] = catBinnedTraces(dataCell);
end

%mean subtract 
if meanSubtract
    meanTrace = mean(traces,3);
    traces = bsxfun(@minus, traces, meanTrace);
end

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%zScore traces 
zTraces = zScoreTraces(traces);
<<<<<<< Updated upstream
=======
% zTraces = traces;
>>>>>>> Stashed changes

%get maze points
mazePoints = getMazePoints(zTraces,yPosBins);

%get nPoints
[nNeurons,nPoints,~] = size(mazePoints);

%get uniqueClusters in each point
uniqueClusters = arrayfun(@(x) unique(clusterIDs(:,x)),1:nPoints,'UniformOutput',false);
nUnique = cellfun(@length,uniqueClusters);

%shuffle cluster 
if shouldShuffle 
    for point = 1:nPoints
        clusterIDs(:,point) = shuffleArray(clusterIDs(:,point));
    end
    clusterIDs = shuffleClusterIDs(clusterIDs);
end

%get cluster sort order
sortOrder = cell(nPoints,1);
if ~strcmpi(sortBy,'none') && ~isempty(cMat)
    for point = 1:nPoints
        [~,sortOrder{point}] = sort(cMat.(sortBy){point});
        sortOrder{point} = flipud(sortOrder{point});
    end
else
    for point = 1:nPoints
        sortOrder{point} = true(nUnique(point),1);
    end
end

%get mean traces
clustTraces = cell(nPoints,1);
trialTraces = cell(nPoints,1);
clustCounts = cell(nPoints,1);
for point = 1:nPoints
    clustTraces{point} = nan(nNeurons,nUnique(point));
    trialTraces{point} = cell(nUnique(point),1);
    for cluster = 1:nUnique(point)
        %get matching indices 
        keepInd = clusterIDs(:,point) == uniqueClusters{point}(cluster);
        
        %take average 
        clustTraces{point}(:,cluster) = mean(mazePoints(:,point,keepInd),3);
        
        %take trial traces
        trialTraces{point}{cluster} = squeeze(mazePoints(:,point,keepInd));
    end
    [~,clustCounts{point}] = count_unique(clusterIDs(:,point));
    clustCounts{point} = clustCounts{point}(sortOrder{point});
    %sort 
    clustTraces{point} = clustTraces{point}(:,sortOrder{point});
    trialTraces{point} = cat(2,trialTraces{point}{sortOrder{point}});
%     trialTraces{point} = cat(2,trialTraces{point}{:});
end




