function clustTraces = getClusteredNeuronalActivity(dataCell,clusterIDs,cMat,varargin)
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


%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'sortby'
                sortBy = varargin{argInd+1};
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

%get uniqueClusters in each point
uniqueClusters = arrayfun(@(x) unique(clusterIDs(:,x)),1:nPoints,'UniformOutput',false);
nUnique = cellfun(@length,uniqueClusters);

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
for point = 1:nPoints
    clustTraces{point} = nan(nNeurons,nUnique(point));
    for cluster = 1:nUnique(point)
        %get matching indices 
        keepInd = clusterIDs(:,point) == uniqueClusters{point}(cluster);
        
        %take average 
        clustTraces{point}(:,cluster) = mean(mazePoints(:,point,keepInd),3);
    end
    %sort 
    clustTraces{point} = clustTraces{point}(:,sortOrder{point});
end




