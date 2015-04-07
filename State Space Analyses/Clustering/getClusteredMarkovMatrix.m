function [mMat,cMat] = getClusteredMarkovMatrix(dataCell)
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
%
%ASM 4/15

segRanges = 0:80:480;
nBinsAvg = 4;
range = [0.5 0.75];
nPoints = 10;

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%get tracs
[~,traces] = catBinnedTraces(dataCell);

%get nNeurons
[nNeurons, ~, nTrials] = size(traces);

%%%%%%%%% Create matrix of values at each point in the maze

%initialize array 
tracePoints = nan(nNeurons,nPoints,nTrials);

%fill in pre-seg
preSegInd = find(yPosBins < segRanges(1),1,'last') - nBinsAvg + 1:find(yPosBins < segRanges(1),1,'last');
tracePoints(:,1,:) = mean(traces(:,preSegInd,:),2);

%fill in each segment
for segInd = 1:length(segRanges)-1
    matchInd = find(yPosBins >= segRanges(segInd) & yPosBins < segRanges(segInd+1));
    binRange = round(range*length(matchInd));
    binRange = binRange + find(yPosBins >= segRanges(segInd),1,'first');
    tracePoints(:,segInd+1,:) = mean(traces(:,binRange(1):binRange(2),:),2);
end

% fill in early delay
offset = 4;
earlyDelayInd = find(yPosBins > segRanges(end),1,'first') + offset:...
    find(yPosBins > segRanges(end),1,'first') + offset + nBinsAvg;
tracePoints(:,8,:) = mean(traces(:,earlyDelayInd,:),2);

% fill in late delay
offset = 10;
lateDelayInd = find(yPosBins > segRanges(end),1,'first') + offset:...
    find(yPosBins > segRanges(end),1,'first') + offset + nBinsAvg;
tracePoints(:,9,:) = mean(traces(:,lateDelayInd,:),2);

% fill in turn
tracePoints(:,end,:) = mean(traces(:,end-nBinsAvg:end-1,:),2);

%%%%%%%%%%%% cluster 
clusterIDs = nan(nTrials,nPoints);
for point = 1:nPoints
   clusterIDs(:,point) = apClusterNeuronalStates(squeeze(tracePoints(:,point,:)));
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