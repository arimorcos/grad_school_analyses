function cMat = getClusterCMat(clusterIDs,dataCell)
%getClusterCMat.m Calculates the value of various behavioral parameters for
%each cluster
%
%INPUTS
%clusterIDs - nTrials x nPoints array of cluster ids 
%dataCell - dataCell from which clusters were generated
%
%
%OUTPUTS
%cMat - structure containing cluster labels for different properties
%
%ASM 4/15

%% get relevant behavioral variables

%get nPoints
nPoints = size(clusterIDs,2);

%get number of unique
uniqueClusters = arrayfun(@(x) unique(clusterIDs(:,x)),1:nPoints,'UniformOutput',false);
nUnique = cellfun(@length,uniqueClusters);

%% get color labels

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