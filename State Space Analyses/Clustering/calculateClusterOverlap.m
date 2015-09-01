function [overlapIndex, whichAct,whichOverlap, whichNonOverlap, totalSize,actNeurons] =...
    calculateClusterOverlap(dataCell,clusterIDs,cMat,varargin)
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
%nullOverlap - nPoints x 1 cell array containing nClusters x nClusters
%   matrix of null probability overlap indices
%
%ASM 4/15

%% handle inputs
sortBy = 'leftTurn';
zThresh = 1;
shouldShuffle = false;
nBootstrap = 100;
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
[clustTraces,trialTraces,clustCounts] = getClusteredNeuronalActivity(dataCell,clusterIDs,cMat,'sortBy',...
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
whichAct = cell(size(clustTraces));
for point = 1:nPoints
    actNeurons{point} = clustTraces{point} >= zThresh;
    whichAct{point} = find(any(actNeurons{point},2));
end


%% calculate overlap index 
overlapIndex = cell(size(actNeurons));
totalSize = cell(size(actNeurons));
whichOverlap = cell(size(actNeurons));
whichNonOverlap = cell(size(actNeurons));
for point = 1:nPoints
    overlapIndex{point} = ones(nUnique(point));
    whichOverlap{point} = cell(nUnique(point));
    whichNonOverlap{point} = cell(nUnique(point));
    totalSize{point} = nan(nUnique(point));
    for startCluster = 1:nUnique(point)
        for endCluster = startCluster+1:nUnique(point)
            actStart = find(actNeurons{point}(:,startCluster));
            actEnd = find(actNeurons{point}(:,endCluster));
            overlap = length(intersect(actEnd,actStart))/length(union(actEnd,actStart));
            overlapIndex{point}(startCluster,endCluster) = overlap;
            overlapIndex{point}(endCluster,startCluster) = overlap;
            whichOverlap{point}{startCluster,endCluster} = intersect(actEnd,actStart);
            whichNonOverlap{point}{startCluster,endCluster} = setxor(actEnd,actStart);
            totalSize{point}(endCluster,startCluster) = clustCounts{point}(startCluster) + clustCounts{point}(endCluster);
            totalSize{point}(startCluster,endCluster) = clustCounts{point}(startCluster) + clustCounts{point}(endCluster);
        end
    end
    
    %calculate diagonal overlap index 
    tempTraces = trialTraces{point};
    tempCounts = cat(1,1,cumsum(clustCounts{point}));
    for cluster = 1:nUnique(point)
        currTrace = tempTraces(:,tempCounts(cluster):tempCounts(cluster+1));
        bootOverlap = nan(nBootstrap,1);
        nClustTrials = size(currTrace,2);
        nChoose = round(nClustTrials/2);
        for bootInd = 1:nBootstrap
            chooseTrials = false(nClustTrials,1);
            chooseTrials(randsample(nClustTrials,nChoose)) = true;
            firstHalfAct = find(mean(currTrace(:,chooseTrials),2) >= zThresh);
            secondHalfAct = find(mean(currTrace(:,~chooseTrials),2) >= zThresh);
            bootOverlap(bootInd) = length(intersect(firstHalfAct,secondHalfAct))/...
                length(union(firstHalfAct,secondHalfAct));
        end
        overlapIndex{point}(cluster,cluster) = nanmean(bootOverlap);
        totalSize{point}(cluster,cluster) = clustCounts{point}(cluster);
    end
    
    %calculate diagonal overlap index 
%     tempTraces = trialTraces{point};
%     tempCounts = cat(1,1,cumsum(clustCounts{point}));
%     for cluster = 1:nUnique(point)
%         currTrace = tempTraces(:,tempCounts(cluster):tempCounts(cluster+1));
%         activeTrace = currTrace >= zThresh;
%         nClustTrials = size(activeTrace,2);
%         index = 1;
%         if nClustTrials == 1
%             overlapIndex{point}(cluster,cluster) = NaN;
%             continue;
%         end
%         tempOverlap = nan(nchoosek(nClustTrials,2),1);
%         for startTrial = 1:nClustTrials
%             for endTrial = startTrial+1:nClustTrials
%                 tempTrace = activeTrace(:,[startTrial, endTrial]);
%                 nSame = sum(tempTrace,2);
%                 tempOverlap(index) = sum(nSame == 2)/sum(nSame >= 1);
%             end
%         end
%         overlapIndex{point}(cluster,cluster) = nanmean(tempOverlap);
%     end
end

%% calculate null overlap index
% nullOverlap = cell(size(actNeurons));
% for point = 1:nPoints
%     nullOverlap{point} = ones(nUnique(point));
%     for startCluster = 1:nUnique(point)
%         for endCluster = startCluster+1:nUnique(point)
%             actStart = find(actNeurons{point}(:,startCluster));
%             actEnd = find(actNeurons{point}(:,endCluster));
%             overlap = length(intersect(actEnd,actStart))/length(union(actEnd,actStart));
%             nullOverlap{point}(startCluster,endCluster) = overlap;
%             nullOverlap{point}(endCluster,startCluster) = overlap;
%         end
%     end
% end
    