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

cMat.mode = 'points';

%get nPoints
nPoints = size(clusterIDs,2);

%get number of unique
uniqueClusters = arrayfun(@(x) unique(clusterIDs(:,x)),1:nPoints,'UniformOutput',false);
nUnique = cellfun(@length,uniqueClusters);

%get counts 
cMat.counts = cell(nPoints,1);
for point = 1:nPoints
    [~,cMat.counts{point}] = count_unique(clusterIDs(:,point));
end

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

%get binned data frames
binnedDF = catBinnedDataFrames(dataCell);
cmScale = 0.75;
dfPoints = getMazePoints(binnedDF,dataCell{1}.imaging.yPosBins);

%yPosition 
cMat.yPosition = cell(nPoints,1);
cMat.dPoints.yPosition = cell(nPoints,1);
yPos = squeeze(dfPoints(3,:,:));
yPos = yPos*cmScale;
for point = 1:nPoints
    cMat.yPosition{point} = nan(nUnique(point),1);
    cMat.dPoints.yPosition{point} = cell(nUnique(point),1);
    for cluster = 1:nUnique(point)
        dPoints = yPos(point,clusterIDs(:,point) ==...
            uniqueClusters{point}(cluster));
        cMat.yPosition{point}(cluster) = nanmean(dPoints);
        cMat.dPoints.yPosition{point}{cluster} = dPoints;
    end
end

%xPosition 
cMat.xPosition = cell(nPoints,1);
cMat.dPoints.xPosition = cell(nPoints,1);
xPos = squeeze(dfPoints(2,:,:));
xPos = xPos*cmScale;
for point = 1:nPoints
    cMat.xPosition{point} = nan(nUnique(point),1);
    cMat.dPoints.xPosition{point} = cell(nUnique(point),1);
    for cluster = 1:nUnique(point)
        dPoints = xPos(point,clusterIDs(:,point) ==...
            uniqueClusters{point}(cluster));
        cMat.xPosition{point}(cluster) = nanmean(dPoints);
        cMat.dPoints.xPosition{point}{cluster} = dPoints;
    end
end

%yVelocity 
cMat.yVelocity = cell(nPoints,1);
cMat.dPoints.yVelocity = cell(nPoints,1);
yVel = squeeze(dfPoints(6,:,:));
yVel = yVel*cmScale;
for point = 1:nPoints
    cMat.yVelocity{point} = nan(nUnique(point),1);
    cMat.dPoints.yVelocity{point} = cell(nUnique(point),1);
    for cluster = 1:nUnique(point)
        dPoints = yVel(point,clusterIDs(:,point) ==...
            uniqueClusters{point}(cluster));
        cMat.yVelocity{point}(cluster) = nanmean(dPoints);
        cMat.dPoints.yVelocity{point}{cluster} = dPoints;
    end
end

%xVelocity  
cMat.xVelocity = cell(nPoints,1);
cMat.dPoints.xVelocity = cell(nPoints,1);
xVel = squeeze(dfPoints(5,:,:));
xVel = xVel*cmScale;
for point = 1:nPoints
    cMat.xVelocity{point} = nan(nUnique(point),1);
    cMat.dPoints.xVelocity{point} = cell(nUnique(point),1);
    for cluster = 1:nUnique(point)
        dPoints = xVel(point,clusterIDs(:,point) ==...
            uniqueClusters{point}(cluster));
        cMat.xVelocity{point}(cluster) = nanmean(dPoints);
        cMat.dPoints.xVelocity{point}{cluster} = dPoints;
    end
end

%view angle  
cMat.viewAngle = cell(nPoints,1);
cMat.dPoints.viewAngle = cell(nPoints,1);
theta = squeeze(dfPoints(4,:,:));
theta = rad2deg(theta) - 90;
for point = 1:nPoints
    cMat.viewAngle{point} = nan(nUnique(point),1);
    cMat.dPoints.viewAngle{point} = cell(nUnique(point),1);
    for cluster = 1:nUnique(point)
        dPoints = theta(point,clusterIDs(:,point) ==...
            uniqueClusters{point}(cluster));
        cMat.viewAngle{point}(cluster) = nanmean(dPoints);
        cMat.dPoints.viewAngle{point}{cluster} = dPoints;
    end
end