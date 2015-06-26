function cMat = getClusterCMatOneClustering(clusterIDs,dataCell)
%getClusterCMatOneClustering.m Calculates the value of various behavioral parameters for
%each cluster when all points clustered together
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

cMat.mode = 'one';

%get nPoints
[nTrials, nPoints] = size(clusterIDs);

%get number of unique clusters
uniqueClusters = unique(clusterIDs(:));
nUnique = length(uniqueClusters);

%get unique point clusters 
uniquePointClusters = arrayfun(@(x) unique(clusterIDs(:,x)),1:nPoints,'UniformOutput',false);
nUniquePoint = cellfun(@length,uniquePointClusters);

cMat.uniqueClusters = uniqueClusters;
cMat.uniquePointClusters = uniquePointClusters;
cMat.nUniquePoint = nUniquePoint;
cMat.nUnique = nUnique;

%get counts 
cMat.counts = cell(nPoints,1);
for point = 1:nPoints
    [~,temp] = count_unique(clusterIDs(:,point));
    cMat.counts{point} = zeros(nUnique,1);
    cMat.counts{point}(ismember(uniqueClusters, cMat.uniquePointClusters{point})) = ...
        temp;
end

%% get color labels

%net evidence
netEv = getNetEvidence(dataCell);
cMat.netEv = cell(nPoints,1);
netEv = cat(2,zeros(nTrials,1),netEv,repmat(netEv(:,end),1,3));
clusterNetEv = nan(nUnique,1);
for cluster = 1:nUnique
    clusterNetEv(cluster) = mean(netEv(clusterIDs == uniqueClusters(cluster)));
end
for point = 1:nPoints
    cMat.netEv{point} = nan(nUnique,1);
    for cluster = 1:nUnique
        if ismember(uniqueClusters(cluster), uniquePointClusters{point})
            cMat.netEv{point}(cluster) = clusterNetEv(cluster);
        end
    end
end

%currSeg
mazePatterns = getMazePatterns(dataCell);
cMat.currSeg = cell(nPoints,1);
mazePatterns = cat(2,0.5*ones(nTrials,1),mazePatterns,0.5*ones(nTrials,3));
clusterCurrSeg = nan(nUnique,1);
for cluster = 1:nUnique
    clusterCurrSeg(cluster) = mean(mazePatterns(clusterIDs == uniqueClusters(cluster)));
end
for point = 1:nPoints
    cMat.currSeg{point} = nan(nUnique,1);
    for cluster = 1:nUnique
        if ismember(uniqueClusters(cluster), uniquePointClusters{point})
            cMat.currSeg{point}(cluster) = clusterCurrSeg(cluster);
        end
    end
end

%leftTurn
leftTurns = repmat(double(getCellVals(dataCell,'result.leftTurn'))',1,nPoints);
cMat.leftTurn = cell(nPoints,1);
clusterLeftTurn = nan(nUnique,1);
for cluster = 1:nUnique
    clusterLeftTurn(cluster) = mean(leftTurns(clusterIDs == uniqueClusters(cluster)));
end
for point = 1:nPoints
    cMat.leftTurn{point} = nan(nUnique,1);
    for cluster = 1:nUnique
        if ismember(uniqueClusters(cluster), uniquePointClusters{point})
            cMat.leftTurn{point}(cluster) = clusterLeftTurn(cluster);
        end
    end
end


%correct
correct = repmat(double(getCellVals(dataCell,'result.correct'))',1,nPoints);
cMat.correct = cell(nPoints,1);
clusterCorrect = nan(nUnique,1);
for cluster = 1:nUnique
    clusterCorrect(cluster) = mean(correct(clusterIDs == uniqueClusters(cluster)));
end
for point = 1:nPoints
    cMat.correct{point} = nan(nUnique,1);
    for cluster = 1:nUnique
        if ismember(uniqueClusters(cluster), uniquePointClusters{point})
            cMat.correct{point}(cluster) = clusterCorrect(cluster);
        end
    end
end

%prevTurn
prevTurn = repmat(double(getCellVals(dataCell,'result.prevTurn'))',1,nPoints);
cMat.prevTurn = cell(nPoints,1);
clusterPrevTurn = nan(nUnique,1);
for cluster = 1:nUnique
    clusterPrevTurn(cluster) = mean(prevTurn(clusterIDs == uniqueClusters(cluster)));
end
for point = 1:nPoints
    cMat.prevTurn{point} = nan(nUnique,1);
    for cluster = 1:nUnique
        if ismember(uniqueClusters(cluster), uniquePointClusters{point})
            cMat.prevTurn{point}(cluster) = clusterPrevTurn(cluster);
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
yPos = squeeze(dfPoints(3,:,:))';
yPos = yPos*cmScale;
clusterYPos = nan(nUnique,1);
clusterYPosDPoints = cell(nUnique,1);
for cluster = 1:nUnique
    clusterYPosDPoints{cluster} = yPos(clusterIDs == uniqueClusters(cluster));
    clusterYPos(cluster) = mean(clusterYPosDPoints{cluster});
end
for point = 1:nPoints
    cMat.dPoints.yPosition{point} = clusterYPosDPoints;
    cMat.yPosition{point} = nan(nUnique,1);
    for cluster = 1:nUnique
        if ismember(uniqueClusters(cluster), uniquePointClusters{point})
            cMat.yPosition{point}(cluster) = clusterYPos(cluster);
        end
    end
end

%xPosition 
cMat.xPosition = cell(nPoints,1);
cMat.dPoints.xPosition = cell(nPoints,1);
xPos = squeeze(dfPoints(2,:,:))';
xPos = xPos*cmScale;
clusterXPos = nan(nUnique,1);
clusterXPosDPoints = cell(nUnique,1);
for cluster = 1:nUnique
    clusterXPosDPoints{cluster} = xPos(clusterIDs == uniqueClusters(cluster));
    clusterXPos(cluster) = mean(clusterXPosDPoints{cluster});
end
for point = 1:nPoints
    cMat.dPoints.xPosition{point} = clusterXPosDPoints;
    cMat.xPosition{point} = nan(nUnique,1);
    for cluster = 1:nUnique
        if ismember(uniqueClusters(cluster), uniquePointClusters{point})
            cMat.xPosition{point}(cluster) = clusterXPos(cluster);
        end
    end
end

%yVelocity 
cMat.yVelocity = cell(nPoints,1);
cMat.dPoints.yVelocity = cell(nPoints,1);
yVel = squeeze(dfPoints(6,:,:))';
yVel = yVel*cmScale;
clusterYVel = nan(nUnique,1);
clusterYVelDPoints = cell(nUnique,1);
for cluster = 1:nUnique
    clusterYVelDPoints{cluster} = yVel(clusterIDs == uniqueClusters(cluster));
    clusterYVel(cluster) = mean(clusterYVelDPoints{cluster});
end
for point = 1:nPoints
    cMat.dPoints.yVelocity{point} = clusterYVelDPoints;
    cMat.yVelocity{point} = nan(nUnique,1);
    for cluster = 1:nUnique
        if ismember(uniqueClusters(cluster), uniquePointClusters{point})
            cMat.yVelocity{point}(cluster) = clusterYVel(cluster);
        end
    end
end

%xVelocity  
cMat.xVelocity = cell(nPoints,1);
cMat.dPoints.xVelocity = cell(nPoints,1);
xVel = squeeze(dfPoints(5,:,:))';
xVel = xVel*cmScale;
clusterXVel = nan(nUnique,1);
clusterXVelDPoints = cell(nUnique,1);
for cluster = 1:nUnique
    clusterXVelDPoints{cluster} = xVel(clusterIDs == uniqueClusters(cluster));
    clusterXVel(cluster) = mean(clusterXVelDPoints{cluster});
end
for point = 1:nPoints
    cMat.dPoints.xVelocity{point} = clusterXVelDPoints;
    cMat.xVelocity{point} = nan(nUnique,1);
    for cluster = 1:nUnique
        if ismember(uniqueClusters(cluster), uniquePointClusters{point})
            cMat.xVelocity{point}(cluster) = clusterXVel(cluster);
        end
    end
end

%view angle  
cMat.viewAngle = cell(nPoints,1);
cMat.dPoints.viewAngle = cell(nPoints,1);
theta = squeeze(dfPoints(4,:,:))';
theta = rad2deg(theta) - 90;
clusterTheta = nan(nUnique,1);
clusterThetaDPoints = cell(nUnique,1);
for cluster = 1:nUnique
    clusterThetaDPoints{cluster} = theta(clusterIDs == uniqueClusters(cluster));
    clusterTheta(cluster) = mean(clusterThetaDPoints{cluster});
end
for point = 1:nPoints
    cMat.dPoints.viewAngle{point} = clusterThetaDPoints;
    cMat.viewAngle{point} = nan(nUnique,1);
    for cluster = 1:nUnique
        if ismember(uniqueClusters(cluster), uniquePointClusters{point})
            cMat.viewAngle{point}(cluster) = clusterTheta(cluster);
        end
    end
end