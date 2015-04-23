function [clusterCorr] = calculateClusterCorrelation(dataCell,clusterIDs,cMat,varargin)
%calculateClusterCorrelation.m Calculates the correlation between clusters
%
%INPUTS
%dataCell - dataCell containing imaging data
%clusterIDs - clusterIDs output by getClusteredMarkovMatrix
%cMat - CMat output by getClusteredMarkovMatrix
%
%OPTIONAL INPUTS
%sortBy - variable to sort clusters by 
%
%OUTPUTS
%clusterCorr - nPoints x 1 cell array containing nClusters x nClusters
%   matrix of correlation coefficients
%
%ASM 4/15

%% handle inputs
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

%% get clustered traces
clustTraces = getClusteredNeuronalActivity(dataCell,clusterIDs,cMat,'sortBy',...
    sortBy);
nPoints = length(clustTraces);
nUnique = cellfun(@(x) size(x,2),clustTraces);


%% calculate correlation coefficient  
clusterCorr = cell(size(clustTraces));
for point = 1:nPoints
    clusterCorr{point} = ones(nUnique(point));
    for startCluster = 1:nUnique(point)
        for endCluster = startCluster+1:nUnique(point)
            actStart = clustTraces{point}(:,startCluster);
            actEnd = clustTraces{point}(:,endCluster);
            corr = corrcoef(actStart,actEnd);
            clusterCorr{point}(startCluster,endCluster) = corr(2,1);
            clusterCorr{point}(endCluster,startCluster) = corr(2,1);
        end
    end
end

    