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

%% get clustered traces
[clustTraces,trialTraces,clustCounts] = getClusteredNeuronalActivity(dataCell,clusterIDs,cMat,'sortBy',...
    sortBy,'shouldShuffle',shouldShuffle);
nPoints = length(clustTraces);
nUnique = cellfun(@(x) size(x,2),clustTraces);
%shuffle 
% if shouldShuffle 
%     for point = 1:nPoints
%         for cluster = 1:nUnique(point)
%             clustTraces{point}(:,cluster) = shuffleArray(clustTraces{point}(:,cluster));
%         end
%         for trial = 1:size(trialTraces,2)
%             trialTraces{point}(:,trial) = shuffleArray(trialTraces{point}(:,trial));
%         end
%     end
% end

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

%     tempTraces = trialTraces{point};
%     tempCounts = cat(1,1,cumsum(clustCounts{point}));
%     for startCluster = 1:nUnique(point)
%         for endCluster = startCluster+1:nUnique(point)
%             startActivity = tempTraces(:,tempCounts(startCluster):tempCounts(startCluster+1));
%             endActivity = tempTraces(:,tempCounts(endCluster):tempCounts(endCluster+1));
%             corr = 1-pdist2(startActivity',endActivity','correlation');
%             corr = nanmean(corr(:));
%             clusterCorr{point}(startCluster,endCluster) = corr;
%             clusterCorr{point}(endCluster,startCluster) = corr;
%         end
%     end
    
% %     %calculate diagonal overlap index 
%     tempTraces = trialTraces{point};
%     tempCounts = cat(1,1,cumsum(clustCounts{point}));
%     for cluster = 1:nUnique(point)
%         currTrace = tempTraces(:,tempCounts(cluster):tempCounts(cluster+1));
%         clusterCorr{point}(cluster,cluster) = nanmean(1-pdist(currTrace','correlation'));
%     end
    
    %calculate diagonal overlap index 
    nBootstrap = 20;
    tempTraces = trialTraces{point};
    tempCounts = cat(1,1,cumsum(clustCounts{point}));
    for cluster = 1:nUnique(point)
        currTrace = tempTraces(:,tempCounts(cluster):tempCounts(cluster+1));
        bootCorr = nan(nBootstrap,1);
        nClustTrials = size(currTrace,2);
        nChoose = round(nClustTrials/2);
        for bootInd = 1:nBootstrap
            chooseTrials = false(nClustTrials,1);
            chooseTrials(randsample(nClustTrials,nChoose)) = true;
            firstHalfAct = mean(currTrace(:,chooseTrials),2);
            secondHalfAct = mean(currTrace(:,~chooseTrials),2);
            tempCorr = corrcoef(firstHalfAct,secondHalfAct);
            bootCorr(bootInd) = tempCorr(2,1);
        end
        clusterCorr{point}(cluster,cluster) = nanmean(bootCorr);
    end
    
end

    