function [overlapIndex,clusterCorr,transMat,deltaEpochs] =...
    calcClusterOverlapCorrAcrossEpochs(dataCell,clusterIDs,cMat,varargin)
%calcClusterOverlapCorrAcrossEpochs.m Calculates the overlap, correlation,
%and transition probabilities across clusters at all epochs
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
%overlapIndex - nTotalClusters x nTotalClusters array of overlap indices
%clusterCorr - nTotalClusters x nTotalClusters array of correlation
%   coefficients
%transMat - nTotalClusters x nTotalClusters array of transition
%   probabilities
%deltaEpochs - nTotalClusters x nTotalClusters array of epochs separating
%   clusters
%
%ASM 10/15

%% handle inputs
sortBy = 'none';
zThresh = 0.3;
pairwiseCorr = true;

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
            case 'pairwisecorr'
                pairwiseCorr = varargin{argInd+1};
        end
    end
end

%% get clustered traces
[clustTraces,trialTraces,~] = getClusteredNeuronalActivity(dataCell,clusterIDs,cMat,'sortBy',...
    sortBy,'shouldShuffle',false);
nPoints = length(clustTraces);
nUnique = cellfun(@(x) size(x,2),clustTraces);
nTotal = sum(nUnique);

whichUnique = cell(nPoints,1);
for point = 1:nPoints
    whichUnique{point} = unique(clusterIDs(:,point));
end
allUnique = cat(1,whichUnique{:});

%% group into single matrix

% group cluster traces together
allClustTraces = cat(2, clustTraces{:});

% get delta epochs
epochNum = nan(nTotal, 1);
cumUnique = cat(1,0,cumsum(nUnique));
for point = 1:nPoints
    epochNum(cumUnique(point)+1:cumUnique(point+1)) = point;
end
deltaEpochs = pdist2(epochNum,epochNum,'euclidean');


%% calculate overlap
% binarize
actNeurons = allClustTraces >= zThresh;

% initialize
overlapIndex = nan(nTotal);

% calculate overlap
for startCluster = 1:nTotal
    for endCluster = startCluster+1:nTotal
        actStart = find(actNeurons(:,startCluster));
        actEnd = find(actNeurons(:,endCluster));
        overlap = length(intersect(actEnd,actStart))/...
            length(union(actEnd,actStart));
        overlapIndex(startCluster,endCluster) = overlap;
        overlapIndex(endCluster,startCluster) = overlap;
        
    end
end

% set diagonal to 1
overlapIndex(logical(eye(nTotal))) = 1;

%% calculate correlation coefficients
%initialize
clusterCorr = nan(nTotal);

%calcualte correlation
for startCluster = 1:nTotal
    for endCluster = startCluster+1:nTotal
        if pairwiseCorr
            
            %get which epoch and which cluster
            whichEpochStart = epochNum(startCluster);
            whichEpochEnd = epochNum(endCluster);
            whichClusterStart = allUnique(startCluster);
            whichClusterEnd = allUnique(endCluster);
            
            %get the trialTraces which correspond for each 
            startTraces = trialTraces{whichEpochStart}(:,...
                clusterIDs(:,whichEpochStart)==whichClusterStart);
            endTraces = trialTraces{whichEpochEnd}(:,...
                clusterIDs(:,whichEpochEnd)==whichClusterEnd);
            
            allPairCorr = 1 - pdist2(startTraces',endTraces','correlation');
            tempCorr = mean(allPairCorr(:));
            clusterCorr(startCluster,endCluster) = tempCorr;
            clusterCorr(endCluster,startCluster) = tempCorr;
                        
        else
            actStart = allClustTraces(:,startCluster);
            actEnd = allClustTraces(:,endCluster);
            corr = corrcoef(actStart,actEnd);
            clusterCorr(startCluster,endCluster) = corr(2,1);
            clusterCorr(endCluster,startCluster) = corr(2,1);
        end
    end
end

% set diagonal to 1
clusterCorr(logical(eye(nTotal))) = 1;

%% calculate transition probabilities
transMat = nan(nTotal);

for startCluster = 1:nTotal
    for endCluster = startCluster+1:nTotal
        %skip if same epoch
        if deltaEpochs(startCluster,endCluster) == 0
            continue;
        end
        
        %get which epoch and which cluster
        whichEpochStart = epochNum(startCluster);
        whichEpochEnd = epochNum(endCluster);
        whichClusterStart = allUnique(startCluster);
        whichClusterEnd = allUnique(endCluster);
        
        %calculate transition probabilities
        whichTrialsStart = find(...
            clusterIDs(:,whichEpochStart) == whichClusterStart);
        whichTrialsEnd = find(...
            clusterIDs(:,whichEpochEnd) == whichClusterEnd);
        
        %store
        transMat(startCluster,endCluster) = ...
            length(intersect(whichTrialsStart,whichTrialsEnd))/...
            length(whichTrialsStart);
    end
end