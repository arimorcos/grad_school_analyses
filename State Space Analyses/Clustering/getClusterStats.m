function stats = getClusterStats(dataCell,varargin)
%getClusterStats.m Extracts cluster statistics, including number of neurons
%active in each cluster, total number of clusters, number of trials in each
%cluster, number of clusters across epochs each neuron is active in,
%relative number of clusters in one clustering vs. individual clusters, and
%the pairwise intra/inter cluster correlation
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OPTIONAL INPUTS
%   traceType - which trace to use
%   zThresh - array of z thresholds to use
%
%OUTPUTS
%stats - structure containing cluster statistics
%
%ASM 8/15

traceType = 'deconv';
zThresh = [0 0.25 0.5 0.75 1];
range = [0.5 0.75];
perc = 10;
clusterIDs = [];
oneClusterIDs = [];
cMat = [];

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'tracetype'
                traceType = varargin{argInd+1};
            case 'zthresh'
                zThresh = varargin{argInd+1};
            case 'range'
                range = varargin{argInd+1};
            case 'perc'
                perc = varargin{argInd+1};
            case 'clusterids'
                clusterIDs = varargin{argInd+1};
            case 'cmat'
                cMat = varargin{argInd+1};
            case 'oneclusterids'
                oneClusterIDs = varargin{argInd+1};
        end
    end
end

nPoints = 10;

if ~isempty(clusterIDs) && ~isempty(cMat)
    [~,cMat,clusterIDs,~] = getClusteredMarkovMatrix(dataCell,...
        'perc',perc,'range',range,'tracetype',traceType);
end
if ~isempty(oneClusterIDs)
    [~,~,oneClusterIDs,~] = getClusteredMarkovMatrix(dataCell,...
        'perc',perc,'range',range,'tracetype',traceType,'oneclustering',true);
end

%get number of neurons active in each cluster
nThresh = length(zThresh);
actNeurons = cell(nThresh,nPoints);
nActive = cell(nThresh,nPoints);
nActiveCat = [];
[clustTraces,trialTraces,clustCounts] = getClusteredNeuronalActivity(dataCell,...
    clusterIDs,cMat,'shouldShuffle',false);
nNeurons = size(clustTraces{1},1);
isAct = nan(nNeurons,nPoints,nThresh);
for threshInd = 1:nThresh
    for point = 1:nPoints
        actNeurons{threshInd,point} = clustTraces{point} >= zThresh(threshInd);
        nActive{threshInd,point} = sum(actNeurons{threshInd,point});
        isAct(:,point,threshInd) = any(actNeurons{threshInd,point},2);
    end
    nActiveCat(threshInd,:) = cat(2,nActive{threshInd,:});
end
nActiveCatFrac = nActiveCat/nNeurons;

%get number of clusters across epochs a given neuron is active in
nEpochsActive = nan(nNeurons,nThresh);
for threshInd = 1:nThresh
    nEpochsActive(:,threshInd) = sum(isAct(:,:,threshInd),2);
end

%get number of clusters for one clustering vs ind clustering
nUniqueEachPoint = arrayfun(@(x) length(unique(clusterIDs(:,x))),1:nPoints);
nUniqueTotalInd = sum(nUniqueEachPoint);
nUniqueOneCluster = length(unique(oneClusterIDs(:)));
relNClustersIndOne = nUniqueTotalInd/nUniqueOneCluster;

%get the fraction of the time a trial in in the same cluster as a function
%   of epochs in the one clustring framework
nTrials = size(oneClusterIDs,1);
fracSame = cell(nPoints-1,1);
for startPoint = 1:nPoints
    for endPoint = startPoint+1:nPoints
        startTrials = oneClusterIDs(:,startPoint);
        endTrials = oneClusterIDs(:,endPoint);
        deltaEpoch = endPoint - startPoint;
        fracSame{deltaEpoch} = cat(1,fracSame{deltaEpoch},...
            startTrials == endTrials);
    end
end
fracSameCluster = cellfun(@(x) sum(x)/length(x),fracSame);

%get the fraction of the time two neurons are in the same cluster at one
%   point that they are at a later point as well
fracStillTogether = cell(2*nPoints - 1, nThresh);
for threshInd = 1:nThresh
    for startPoint = 1:nPoints
        
        for endPoint = 1:nPoints
            startNeurons = find(isAct(:,startPoint,threshInd));
            endNeurons = find(isAct(:,endPoint,threshInd));
            
            %find each start pair 
            startPairs = allcomb(startNeurons,startNeurons);
            removeInd = startPairs(:,1) >= startPairs(:,2);
            startPairs(removeInd,:) = [];
            
            %find each end pair 
            endPairs = allcomb(endNeurons,endNeurons);
            removeInd = endPairs(:,1) >= endPairs(:,2);
            endPairs(removeInd,:) = [];
            
            %find overlapping pairs 
            [~,overlaps] = intersect(startPairs,endPairs,'rows');
            stillCoactive = false(size(startPairs,1),1);
            stillCoactive(overlaps) = true;
            
            %get frac still together 
            pointInd = endPoint - startPoint + nPoints;
            fracStillTogether{pointInd,threshInd} = cat(1,...
                fracStillTogether{pointInd,threshInd},stillCoactive);
        end
        
    end
end
fracStillTogether = cellfun(@(x) sum(x)/length(x),fracStillTogether);

%get number of trials in each cluster
nTrialsEachCluster = cat(1,clustCounts{:});

%get pairwise intra/inter distance
clusterCorr = cell(size(clustTraces));
for point = 1:nPoints
    %get current traces
    tempTraces = trialTraces{point};
    
    %get sort ind for clusters
    [~,sortInd] = sort(clusterIDs(:,point));
    
    %sort traces
    tempTraces = tempTraces(:,sortInd);
    
    %get pairwise correlation coefficient
    clusterCorr{point} = squareform(1-pdist(tempTraces','correlation'));
    identity = logical(eye(size(tempTraces,2)));
    clusterCorr{point}(identity) = 1;
    
end
%% store
% parameters
stats.zThresh = zThresh;

%number of clusters
stats.nUniqueEachPoint = nUniqueEachPoint;
stats.nUniqueOneCluster = nUniqueOneCluster;
stats.relNClustersIndOne = relNClustersIndOne;

%epochs active
stats.nEpochsActive = nEpochsActive;

%number of active neurons
stats.nActiveCat = nActiveCat;
stats.nActiveCatFrac = nActiveCatFrac;

%number of trials in the same cluster across epochs
stats.fracSameCluster = fracSameCluster;

%number of trials in each cluster
stats.nTrialsEachCluster = nTrialsEachCluster;

%number of neurons still together 
stats.fracStillTogether = fracStillTogether;
