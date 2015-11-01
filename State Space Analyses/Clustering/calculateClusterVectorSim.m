function [clusterVecSim] = calculateClusterVectorSim(...
    dataCell,clusterIDs,cMat,varargin)
%calculateClusterVectorSim.m Calculates the vector similarity between clusters
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
shouldShuffle = false;
meanSubtract = true;

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

%% get clustered traces
[clustTraces,trialTraces,clustCounts] = getClusteredNeuronalActivity(dataCell,clusterIDs,cMat,'sortBy',...
    sortBy,'shouldShuffle',shouldShuffle,'meanSubtract',meanSubtract);
nPoints = length(clustTraces);
nUnique = cellfun(@(x) size(x,2),clustTraces);

%% calculate vector similarity
clusterVecSim = cell(size(clustTraces));
for point = 1:nPoints
    clusterVecSim{point} = ones(nUnique(point));
    for startCluster = 1:nUnique(point)
        for endCluster = startCluster+1:nUnique(point)
            actStart = clustTraces{point}(:,startCluster);
            actEnd = clustTraces{point}(:,endCluster);
            clusterSim = cosineSimilarity(actStart,actEnd);
            clusterVecSim{point}(startCluster,endCluster) = clusterSim;
            clusterVecSim{point}(endCluster,startCluster) = clusterSim;
        end
    end
    
    %calculate diagonal overlap index 
    nBootstrap = 20;
    tempTraces = trialTraces{point};
    tempCounts = cat(1,1,cumsum(clustCounts{point}));
    for cluster = 1:nUnique(point)
        currTrace = tempTraces(:,tempCounts(cluster):tempCounts(cluster+1));
        bootVecSim = nan(nBootstrap,1);
        nClustTrials = size(currTrace,2);
        nChoose = round(nClustTrials/2);
        for bootInd = 1:nBootstrap
            chooseTrials = false(nClustTrials,1);
            chooseTrials(randsample(nClustTrials,nChoose)) = true;
            firstHalfAct = mean(currTrace(:,chooseTrials),2);
            secondHalfAct = mean(currTrace(:,~chooseTrials),2);
            tempSim = cosineSimilarity(firstHalfAct,secondHalfAct);
            bootVecSim(bootInd) = tempSim;
        end
        clusterVecSim{point}(cluster,cluster) = nanmean(bootVecSim);
    end
    
end

    