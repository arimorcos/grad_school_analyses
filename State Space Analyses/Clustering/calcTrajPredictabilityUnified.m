function [acc,sigMat,deltaPoint,nUnique] = calcTrajPredictabilityUnified(dataCell,varargin)
%calcTrajPredictabilityUnified.m Quantifies the variability due to internal
%at each segment. Asks given knowledge of the current cluster, can you
%predict the the next cluster? What about the n+2 cluster?
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%
%OUTPUTS
%acc - nPoints x nPoints array of accuracy
%sigMat - nPoints x nPoints array of significance. 0 - not significant, 1 -
%   p < 0.05, 2 - p < 0.01, 3 - p < 0.001
%deltaPoint - structure with two fields:
%
%ASM 4/15

oneClustering = false;
nShuffles = 100;
useBehavior = false;
shuffleInitial = false;
perc = 10;
whichNeurons = [];
traceType = 'deconv';
filterAutoCorr = false;
filterAutoCorrThresh = 0.05;
filterAutoCorrLag = 2;
filterAutoCorrRemoveRandom = false;
binarize = false;
binarizeThresh = 0.5;

if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'binarize'
                binarize = varargin{argInd+1};
            case 'binarizethresh'
                binarizeThresh = varargin{argInd+1};
            case 'filterautocorrremoverandom'
                filterAutoCorrRemoveRandom = varargin{argInd+1};
            case 'filterautocorr'
                filterAutoCorr = varargin{argInd+1};
            case 'filterautocorrthresh'
                filterAutoCorrThresh = varargin{argInd+1};
            case 'filterautocorrlag'
                filterAutoCorrLag = varargin{argInd+1};
            case 'nshuffles'
                nShuffles = varargin{argInd+1};
            case 'usebehavior'
                useBehavior = varargin{argInd+1};
            case 'shuffleinitial'
                shuffleInitial = varargin{argInd+1};
            case 'oneclustering'
                oneClustering = varargin{argInd+1};
            case 'perc'
                perc = varargin{argInd+1};
            case 'whichneurons'
                whichNeurons = varargin{argInd+1};
            case 'tracetype'
                traceType = varargin{argInd+1};
        end
    end
end

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%subset to 6-0 trials
dataCell = getTrials(dataCell,'maze.numLeft==0,6');
leftCell = getTrials(dataCell,'maze.numLeft==6');
rightCell = getTrials(dataCell,'maze.numLeft==0');

if useBehavior
    traces = catBinnedDataFrames(dataCell);
    keepVar = 2:6; %2 - xPos, 3 - yPos, 4 - view angle, 5 - xVel, 6 - yVel
    traces = traces(keepVar,:,:);
else
    switch lower(traceType)
        case 'dff'
            %get traces
            [~,leftTraces] = catBinnedTraces(leftCell);
            [~,rightTraces] = catBinnedTraces(rightCell);
        case 'deconv'
            leftTraces = catBinnedDeconvTraces(leftCell);
            rightTraces = catBinnedDeconvTraces(rightCell);
        otherwise 
            error('Can''t interpret trace type');
    end
end

if ~isempty(whichNeurons)
    leftTraces = leftTraces(whichNeurons,:,:);
    rightTraces = rightTraces(whichNeurons,:,:);
end

%get nNeurons
nLeftTrials = size(leftTraces,3);
nRightTrials = size(rightTraces,3);

%%%%%%%%% Create matrix of values at each point in the maze

leftPoints = getMazePoints(leftTraces,yPosBins);
rightPoints = getMazePoints(rightTraces,yPosBins);
allPoints = getMazePoints(cat(3,leftTraces,rightTraces),yPosBins);
nPoints = size(leftPoints,2);

%%%%%%%%%% Filter based on auto corr 
if filterAutoCorr
    
    %get auto corr 
    autoCorr = calcEpochAutoCorr(allPoints);
    
    %crop to appropriate lag 
    autoCorr = autoCorr(:,11-filterAutoCorrLag);
    
    %get neurons to keep 
    keepInd = autoCorr <= filterAutoCorrThresh;
    if filterAutoCorrRemoveRandom
        keepInd = shuffleArray(keepInd);
    end
    
    %filter 
    leftPoints = leftPoints(keepInd,:,:);
    rightPoints = rightPoints(keepInd,:,:);
    
end

if binarize
    leftPoints(leftPoints >= binarizeThresh) = 1;
    leftPoints(leftPoints < binarizeThresh) = 0;
    rightPoints(rightPoints >= binarizeThresh) = 1;
    rightPoints(rightPoints < binarizeThresh) = 0;
end

%%%%%%%%%%%% cluster 

%% left 
if oneClustering
    reshapePoints = reshape(leftPoints,size(leftPoints,1),...
        size(leftPoints,2)*size(leftPoints,3));
    allClusterIDs = apClusterNeuronalStates(reshapePoints, perc);
    clusterIDsLeft = reshape(allClusterIDs,size(leftPoints,3),size(leftPoints,2));
else
    clusterIDsLeft = nan(nLeftTrials,nPoints);
    for point = 1:nPoints
        clusterIDsLeft(:,point) = apClusterNeuronalStates(squeeze(leftPoints(:,point,:)),perc);
        if shuffleInitial
            clusterIDsLeft(:,point) = shuffleArray(clusterIDsLeft(:,point));
        end
    end
end

%%% get unique clusters 
uniqueClustersLeft = cell(nPoints,1);
clusterCountsLeft = cell(nPoints,1);
for point = 1:nPoints
    [uniqueClustersLeft{point},clusterCountsLeft{point}] = count_unique(clusterIDsLeft(:,point));
end
nUniqueLeft = cellfun(@length,uniqueClustersLeft);

%% right 

if oneClustering
    reshapePoints = reshape(rightPoints,size(rightPoints,1),...
        size(rightPoints,2)*size(rightPoints,3));
    allClusterIDs = apClusterNeuronalStates(reshapePoints, perc);
    clusterIDsRight = reshape(allClusterIDs,size(rightPoints,3),size(rightPoints,2));
else
    clusterIDsRight = nan(nRightTrials,nPoints);
    for point = 1:nPoints
        clusterIDsRight(:,point) = apClusterNeuronalStates(squeeze(rightPoints(:,point,:)),perc);
        if shuffleInitial
            clusterIDsRight(:,point) = shuffleArray(clusterIDsRight(:,point));
        end
    end
end

%%% get unique clusters 
uniqueClustersRight = cell(nPoints,1);
clusterCountsRight = cell(nPoints,1);
for point = 1:nPoints
    [uniqueClustersRight{point},clusterCountsRight{point}] = count_unique(clusterIDsRight(:,point));
end
nUniqueRight = cellfun(@length,uniqueClustersRight);

nUnique = round(mean([sum(nUniqueRight),sum(nUniqueLeft)]));

%% calculate accuracy 
isGuessCorrectLeft = getAccuracy(nPoints,nLeftTrials,uniqueClustersLeft,clusterIDsLeft,nUniqueLeft);
isGuessCorrectRight = getAccuracy(nPoints,nRightTrials,uniqueClustersRight,clusterIDsRight,nUniqueRight);
acc = combineAcc(isGuessCorrectLeft,isGuessCorrectRight);

%% shuffle 
shuffleAcc = nan(nPoints,nPoints,nShuffles);
for shuffleInd = 1:nShuffles
    shuffleClustersLeft = clusterIDsLeft;
    shuffleClustersRight = clusterIDsRight;
    for point = 1:nPoints
        shuffleClustersLeft(:,point) = shuffleArray(shuffleClustersLeft(:,point));
        shuffleClustersRight(:,point) = shuffleArray(shuffleClustersRight(:,point));
    end
    tempLeft = getAccuracy(nPoints,nLeftTrials,uniqueClustersLeft,shuffleClustersLeft,nUniqueLeft);
    tempRight = getAccuracy(nPoints,nRightTrials,uniqueClustersRight,shuffleClustersRight,nUniqueRight);
    shuffleAcc(:,:,shuffleInd) = combineAcc(tempLeft,tempRight);
%     dispProgress('Shuffling %d/%d',shuffleInd,shuffleInd,nShuffles);
end

%% get significance 
%calculate significance
p95Bound = prctile(shuffleAcc,[2.5 97.5],3);
p99Bound = prctile(shuffleAcc,[0.5 99.5],3);
p999Bound = prctile(shuffleAcc,[0.05 99.95],3);

sigMat = zeros(nPoints);
sigMat(acc > p95Bound(:,:,2)) = 1;
sigMat(acc > p99Bound(:,:,2)) = 2;
sigMat(acc > p999Bound(:,:,2)) = 3;

%get chance
% chanceAcc = mean(shuffleAcc,3);

% %get std and median
% stdShuffle = std(shuffleAcc,0,3);
% medianShuffle = median(shuffleAcc,3);
% 
% %get nSTD
% nSTDAboveMedian = (acc - medianShuffle)./stdShuffle;

%% get delta point 
if nargout < 3
    return;
end

%get distance matrix
% pointDist = triu(squareform(pdist([1:nPoints]')));
pointDist = squareform(pdist([1:nPoints]'));
pointDist(logical(tril(ones(nPoints)))) = -1*pointDist(logical(tril(ones(nPoints))));

%initialize 
meanAcc = nan(2*nPoints-1,1);
meanNSTD = nan(size(meanAcc));
meanSig = nan(size(meanAcc));
meanChance = nan(size(meanAcc));
chanceBounds = nan(nPoints-1,3,2);

% loop through each delta 
deltaVals = -nPoints+1:nPoints-1;
for deltaInd = 1:2*nPoints-1
    
    %get matchInd
    matchInd = pointDist == deltaVals(deltaInd);
    
    %get meanAcc
    meanAcc(deltaInd) = mean(acc(matchInd));
    
    %loop through shuffle and get values 
    meanShuffleAcc = nan(nShuffles,1);
    for shuffleInd = 1:nShuffles 
        tempMat = shuffleAcc(:,:,shuffleInd);
        meanShuffleAcc(shuffleInd) = mean(tempMat(matchInd));
    end
    
    %get chance
    meanChance(deltaInd) = mean(meanShuffleAcc);
    
    %calculate significance
    p95Bound = prctile(meanShuffleAcc,[2.5 97.5]);
    p99Bound = prctile(meanShuffleAcc,[0.5 99.5]);
    p999Bound = prctile(meanShuffleAcc,[0.05 99.95]);

    if meanAcc(deltaInd) > p999Bound(2)
        meanSig(deltaInd) = 3;
    elseif meanAcc(deltaInd) > p99Bound(2)
        meanSig(deltaInd) = 2;
    elseif meanAcc(deltaInd) > p95Bound(2)
        meanSig(deltaInd) = 1;
    end
    
    %store 
    chanceBounds(deltaInd,3,:) = p999Bound;
    chanceBounds(deltaInd,2,:) = p99Bound;
    chanceBounds(deltaInd,1,:) = p95Bound;
    
    %get std and median
    stdShuffle = std(meanShuffleAcc);
    medianShuffle = median(meanShuffleAcc);
    
    %get nSTD
    meanNSTD(deltaInd) = (meanAcc(deltaInd) - medianShuffle)./stdShuffle;
    
end

%store 
deltaPoint.meanAcc = meanAcc;
deltaPoint.meanSig = meanSig;
deltaPoint.meanNSTD = meanNSTD;
deltaPoint.meanChance = meanChance;
deltaPoint.chanceBounds = chanceBounds;

end

function isGuessCorrect = getAccuracy(nPoints,nTrials,uniqueClusters,clusterIDs,nUnique)
isGuessCorrect = cell(nPoints);
for startPoint = 1:nPoints
    for endPoint = 1:nPoints
        
        %skip if same 
        if startPoint == endPoint
            continue;
        end
        
        %initialize array of answers
        trialCorrect = nan(nTrials,1);
        
        %loop through each unique start cluster 
        for clusterInd = 1:nUnique(startPoint)
            
            %get the match ind 
            matchInd = clusterIDs(:,startPoint) == uniqueClusters{startPoint}(clusterInd);
            
            %get the most common end cluster 
            guessCluster = mode(clusterIDs(matchInd,endPoint));
            
            %get correct or not 
            trialCorrect(matchInd) = guessCluster == clusterIDs(matchInd,endPoint);
            
        end
        
        %get accuracy 
        isGuessCorrect{startPoint,endPoint} = trialCorrect;
    end
end
end

function acc = combineAcc(left,right)

acc = nan(size(left));

nPoints = size(left,1);
for startPoint = 1:nPoints
    for endPoint = 1:nPoints
        
        if startPoint == endPoint
            acc(startPoint,endPoint) = NaN;
            continue;
        end
        
        allTrials = cat(1,left{startPoint,endPoint},right{startPoint,endPoint});
        
        acc(startPoint,endPoint) = 100*sum(allTrials)/length(allTrials);
        
    end
end
end




