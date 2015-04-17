function [mMat,cMat,clusterIDs,clusterCenters] = getClusteredMarkovMatrix(dataCell,varargin)
%getClusteredMarkovMatrix.m Creates a markov transition matrix from
%clustered states for several points within the maze
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%mMat - nPoints-1 x 1 cell array of nClustersPointN x
%   nClustersPointN+1 matrix of transition probabilities
%cMat - structure containing cluster labels for different properties
%clusterIDs - nTrials x nPoints array of cluster IDs
%clusterCenters - nPoints x 1 cell array each containing a nNeurons x
%   nClusters array of clusterCenters
%
%ASM 4/15

segRanges = 0:80:480;
nBinsAvg = 4;
range = [0.5 0.75];
nPoints = 10;
clusterType = 'ap';

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'segranges'
                segRanges = varargin{argInd+1};
            case 'nbinsavg'
                nBinsAvg = varargin{argInd+1};
            case 'range'
                range = varargin{argInd+1};
            case 'clustertype'
                clusterType = varargin{argInd+1};
        end
    end
end

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%get tracs
[~,traces] = catBinnedTraces(dataCell);

%get nNeurons
[nNeurons,~,nTrials] = size(traces);

%%%%%%%%% Create matrix of values at each point in the maze

tracePoints = getMazePoints(traces,yPosBins);

%%%%%%%%%%%% cluster
clusterIDs = nan(nTrials,nPoints);
for point = 1:nPoints
    switch lower(clusterType)
        case 'ap'
            clusterIDs(:,point) = apClusterNeuronalStates(squeeze(tracePoints(:,point,:)));
        case 'dbscan'
            clusterIDs(:,point) = dbscanClusterNeuronalStates(squeeze(tracePoints(:,point,:)));
        otherwise
            error('Cannot interpret cluster type: %s',clusterType);
    end
end

%get number of unique
uniqueClusters = arrayfun(@(x) unique(clusterIDs(:,x)),1:nPoints,'UniformOutput',false);
nUnique = cellfun(@length,uniqueClusters);

%%%% get color labels

%net evidence
netEv = getNetEvidence(dataCell);
cMat.netEv = cell(nPoints,1);
for point = 1:nPoints
    if point == 1
        cMat.netEv{point} = zeros(nUnique(point),1);
        continue;
    end
    cMat.netEv{point} = nan(nUnique(point),1);
    for cluster = 1:nUnique(point)
        currNetEv = netEv(:,min(point,6));
        cMat.netEv{point}(cluster) = mean(currNetEv(clusterIDs(:,point) ==...
            uniqueClusters{point}(cluster)));
    end
end

%leftTurn
leftTurns = double(getCellVals(dataCell,'result.leftTurn'));
cMat.leftTurn = cell(nPoints,1);
for point = 1:nPoints
    cMat.leftTurn{point} = nan(nUnique(point),1);
    for cluster = 1:nUnique(point)
        cMat.leftTurn{point}(cluster) = mean(leftTurns(clusterIDs(:,point) ==...
            uniqueClusters{point}(cluster)));
    end
end

%correct
correct = double(getCellVals(dataCell,'result.correct'));
cMat.correct = cell(nPoints,1);
for point = 1:nPoints
    cMat.correct{point} = nan(nUnique(point),1);
    for cluster = 1:nUnique(point)
        cMat.correct{point}(cluster) = mean(correct(clusterIDs(:,point) ==...
            uniqueClusters{point}(cluster)));
    end
end

%prevTurn
prevTurn = double(getCellVals(dataCell,'result.prevTurn'));
cMat.prevTurn = cell(nPoints,1);
for point = 1:nPoints
    cMat.prevTurn{point} = nan(nUnique(point),1);
    for cluster = 1:nUnique(point)
        cMat.prevTurn{point}(cluster) = mean(prevTurn(clusterIDs(:,point) ==...
            uniqueClusters{point}(cluster)));
    end
end

%currSeg
mazePatterns = getMazePatterns(dataCell);
nSeg = size(mazePatterns,2);
cMat.currSeg = cell(nPoints,1);
for point = 1:nPoints
    if point == 1 || point > nSeg + 1
        cMat.currSeg{point} = 0.5*ones(nUnique(point),1);
    else
        cMat.currSeg{point} = nan(nUnique(point),1);
        for cluster = 1:nUnique(point)
            cMat.currSeg{point}(cluster) = mean(mazePatterns(clusterIDs(:,point) ==...
                uniqueClusters{point}(cluster),point-1));
        end
    end
    
end

%%%%% get transitions
transMat = cell(nPoints-1,1);
for point = 1:(nPoints-1)
    
    %initialize transMat
    transMat{point} = zeros(nUnique(point),nUnique(point+1));
    
    % loop through each trial
    for trialInd = 1:nTrials
        currID = find(clusterIDs(trialInd,point) == uniqueClusters{point});
        newID = find(clusterIDs(trialInd,point+1) == uniqueClusters{point+1});
        transMat{point}(currID,newID) = transMat{point}(currID,newID) + 1;
    end
end

%normalize to get mMat
mMat = cellfun(@(x) x./nTrials,transMat,'UniformOutput',false);

%get cluster centers
clusterCenters = cell(nPoints,1);
for point = 1:nPoints
    
    %get unique clusters
    uniqueClusters = sort(unique(clusterIDs(:,point)));
    nClusters = length(uniqueClusters);
    
    %initialize
    clusterCenters{point} = nan(nNeurons,nClusters);
    
    for clusterInd = 1:nClusters
        clusterCenters{point}(:,clusterInd) = ...
            mean(tracePoints(:,point,clusterIDs(:,point) == ...
            uniqueClusters(clusterInd)),3);
    end
end