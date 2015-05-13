function [overlapIndex, whichAct] = calculateAllClusterOverlap(dataCell,clusterIDs,cMat,varargin)
%calculateAllClusterOverlap.m Calculates the total overlap in active neurons between
%all clusters at each point using the threshold specified
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
%overlapIndex - nPoints x 1 array of overlap indices
%
%ASM 4/15

%% handle inputs
sortBy = 'leftTurn';
zThresh = 1;
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
            case 'zthresh'
                zThresh = varargin{argInd+1};
            case 'shouldshuffle'
                shouldShuffle = varargin{argInd+1};
        end
    end
end

%% get clustered traces
[clustTraces,trialTraces] = getClusteredNeuronalActivity(dataCell,clusterIDs,cMat,'sortBy',...
    sortBy,'shouldShuffle',false);
nPoints = length(clustTraces);
nUnique = cellfun(@(x) size(x,2),clustTraces);
%shuffle 
if shouldShuffle 
    for point = 1:nPoints
        for cluster = 1:nUnique(point)
            clustTraces{point}(:,cluster) = shuffleArray(clustTraces{point}(:,cluster));
        end
        for trial = 1:size(trialTraces{1},2)
            trialTraces{point}(:,trial) = shuffleArray(trialTraces{point}(:,trial));
        end
    end
end


%% bin as active or inactive 
actNeurons = cell(size(clustTraces));
for point = 1:nPoints
    actNeurons{point} = clustTraces{point} >= zThresh;
end


%% calculate overlap index 
overlapIndex = nan(nPoints,1);
whichAct = cell(nPoints,1);
nNeurons = size(actNeurons{1},1);
for point = 1:nPoints
    whichAct{point} = find(all(actNeurons{point},2));
    overlapIndex(point) = length(whichAct{point})/nNeurons;
end