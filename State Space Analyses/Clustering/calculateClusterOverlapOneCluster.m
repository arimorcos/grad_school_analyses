function [overlapIndex, whichAct,totalSize] = calculateClusterOverlapOneCluster(dataCell,clusterIDs,cMat,varargin)
%calculateClusterOverlapOneCluster.m Calculates the total overlap in active neurons between
%all clusters using the one clustering method at the the theshold specified
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
%totalSize - nPoints x nPoints array of totalSize for each comparison
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

assert(strcmpi(cMat.mode,'one'),'Must use one clustering method');

%% get clustered traces
[clustTraces, trialTraces] = getClusteredNeuronalActivityOneCluster(dataCell,clusterIDs,cMat,'sortBy',...
    sortBy);

%get info
[~, nClusters] = size(clustTraces);

%% bin as active or inactive 
actNeurons = clustTraces >= zThresh;

%% calculate overlap index 
whichAct = arrayfun(@(x) find(actNeurons(:,x)), 1:nClusters,'UniformOutput',false);
overlapIndex = nan(nClusters);
totalSize = nan(nClusters);
nClusterTrials = cellfun(@(x) size(x,2),trialTraces);
for cluster1 = 1:nClusters
    for cluster2 = cluster1+1:nClusters
        
        % calculate overlap index 
        allAct = union(whichAct{cluster1},whichAct{cluster2});
        if isempty(allAct)
            overlapIndex(cluster1,cluster2) = NaN;
            overlapIndex(cluster2,cluster1) = NaN;
            continue;
        end            
        allOverlap = intersect(whichAct{cluster1},whichAct{cluster2});
        if isempty(allOverlap)
            tempOverlap = 0;
        elseif isempty(allAct)
            continue;
        else
            tempOverlap = length(allOverlap)/length(allAct);
        end
        
        %store 
        overlapIndex(cluster1,cluster2) = tempOverlap;
        overlapIndex(cluster2,cluster1) = tempOverlap;
        totalSize(cluster1,cluster2) = nClusterTrials(cluster1) + nClusterTrials(cluster2);
        totalSize(cluster2,cluster1) = nClusterTrials(cluster1) + nClusterTrials(cluster2);
        
    end
end

overlapIndex(logical(eye(nClusters))) = 1;

%calculate diagonal bootstrap
nBootstrap = 100;
for cluster = 1:nClusters
    %get traces and count 
    tempTraces = trialTraces{cluster};
    clusterCount = size(tempTraces,2);
    
    if isempty(whichAct{cluster})
        overlapIndex(cluster,cluster) = NaN;
        continue;
    end
    
    %initialize 
    bootOverlap = nan(nBootstrap,1);
    nChoose = round(clusterCount/2);
    for bootInd = 1:nBootstrap
        chooseTrials = false(clusterCount,1);
        chooseTrials(randsample(clusterCount,nChoose)) = true;
        firstHalfAct = find(mean(tempTraces(:,chooseTrials),2) >= zThresh);
        secondHalfAct = find(mean(tempTraces(:,~chooseTrials),2) >= zThresh);
        bootOverlap(bootInd) = length(intersect(firstHalfAct,secondHalfAct))/...
                length(union(firstHalfAct,secondHalfAct));
    end
    overlapIndex(cluster,cluster) = nanmean(bootOverlap);
    totalSize(cluster,cluster) = nClusterTrials(cluster);
    
end

%remove nan rows 
nanInd = any(isnan(overlapIndex));
overlapIndex = overlapIndex(~nanInd,~nanInd);
totalSize = totalSize(~nanInd,~nanInd);

