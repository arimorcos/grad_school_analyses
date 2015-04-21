function overlapIndex = calculateClusterOverlap(dataCell,clusterIDs,cMat,varargin)
%calculateClusterOverlap.m Calculates the overlap in active neurons between
%clusters using the threshold specified
%
%INPUTS
%dataCell - dataCell containing imaging data
%clusterIDs - clusterIDs output by getClusteredMarkovMatrix
%cMat - CMat output by getClusteredMarkovMatrix
%
%OPTIONAL INPUTS
%sortBy - variable to sort clusters by 
%zThresh - threshold as standard deviations above mean to count as active 
%
%OUTPUTS
%overlapIndex - nPoints x 1 cell array containing nClusters x nClusters
%   matrix of overlap indices
%
%ASM 4/15

%% handle inputs
sortBy = 'leftTurn';
zThresh = 1;
%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'sortby'
                sortBy = varargin{argInd+1};
            case 'zthresh'
                zThresh = varargin{argInd+1};
        end
    end
end

%% get clustered traces
clustTraces = getClusteredNeuronalActivity(dataCell,clusterIDs,cMat,'sortBy',...
    sortBy);
nPoints = length(clustTraces);
nUnique = cellfun(@(x) size(x,2),clustTraces);
nNeurons = size(clustTraces{1},1);

%% bin as active or inactive 
actNeurons = cell(size(clustTraces));
for point = 1:nPoints
    actNeurons{point} = clustTraces{point} >= zThresh;
end


%% calculate overlap index 
overlapIndex = cell(size(actNeurons));
for point = 1:nPoints
    overlapIndex{point} = ones(nUnique(point));
    for startCluster = 1:nUnique(point)
        for endCluster = startCluster+1:nUnique(point)
            actStart = find(actNeurons{point}(:,startCluster));
            actEnd = find(actNeurons{point}(:,endCluster));
            overlap = length(intersect(actEnd,actStart))/length(union(actEnd,actStart));
            overlapIndex{point}(startCluster,endCluster) = overlap;
            overlapIndex{point}(endCluster,startCluster) = overlap;
        end
    end
end
    