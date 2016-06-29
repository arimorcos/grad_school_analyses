function [acc,sigMat,deltaPoint,nUnique] = ...
    calcTrajPredictabilityAllTrials(dataCell,varargin)
%calcTrajPredictabilityAllTrials.m Quantifies the variability due to internal
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

if useBehavior
    traces = catBinnedDataFrames(dataCell);
    keepVar = 2:6; %2 - xPos, 3 - yPos, 4 - view angle, 5 - xVel, 6 - yVel
    traces = traces(keepVar,:,:);
else
    switch lower(traceType)
        case 'dff'
            %get traces
            [~,traces] = catBinnedTraces(dataCell);
        case 'deconv'
            traces = catBinnedDeconvTraces(dataCell);
        otherwise 
            error('Can''t interpret trace type');
    end
end

if ~isempty(whichNeurons)
    traces = traces(whichNeurons,:,:);
end

%get nNeurons
nTrials = size(traces,3);

%%%%%%%%% Create matrix of values at each point in the maze

mazePoints = getMazePoints(traces,yPosBins);
nPoints = size(mazePoints,2);

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
    mazePoints = mazePoints(keepInd,:,:);
    
end

if binarize
    mazePoints(mazePoints >= binarizeThresh) = 1;
    mazePoints(mazePoints < binarizeThresh) = 0;
end

%%%%%%%%%%%% cluster 

%% left 
if oneClustering
    reshapePoints = reshape(mazePoints,size(mazePoints,1),...
        size(mazePoints,2)*size(mazePoints,3));
    allClusterIDs = apClusterNeuronalStates(reshapePoints, perc);
    clusterIDs = reshape(allClusterIDs,size(mazePoints,3),size(mazePoints,2));
else
    clusterIDs = nan(nTrials,nPoints);
    for point = 1:nPoints
        clusterIDs(:,point) = apClusterNeuronalStates(squeeze(mazePoints(:,point,:)),perc);
        if shuffleInitial
            clusterIDs(:,point) = shuffleArray(clusterIDs(:,point));
        end
    end
end

%%% get unique clusters 
uniqueClusters = cell(nPoints,1);
clusterCounts = cell(nPoints,1);
for point = 1:nPoints
    [uniqueClusters{point},clusterCounts{point}] = ...
        count_unique(clusterIDs(:,point));
end
nUnique = cellfun(@length,uniqueClusters);

%% calculate accuracy 
acc = getAccuracy(nPoints,nTrials,uniqueClusters,clusterIDs,nUnique);
acc = combineAcc(acc);

%% shuffle 
shuffleAcc = nan(nPoints,nPoints,nShuffles);
for shuffleInd = 1:nShuffles
    shuffleClusters = clusterIDs;
    for point = 1:nPoints
        shuffleClusters(:,point) = shuffleArray(shuffleClusters(:,point));
    end
    tempAcc = getAccuracy(nPoints,nTrials,uniqueClusters,shuffleClusters,nUnique);
    shuffleAcc(:,:,shuffleInd) = combineAcc(tempAcc);
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

function acc = combineAcc(left)

acc = nan(size(left));

nPoints = size(left,1);
for startPoint = 1:nPoints
    for endPoint = 1:nPoints
        
        if startPoint == endPoint
            acc(startPoint,endPoint) = NaN;
            continue;
        end
        
        allTrials = left{startPoint,endPoint};
        
        acc(startPoint,endPoint) = 100*sum(allTrials)/length(allTrials);
        
    end
end
end