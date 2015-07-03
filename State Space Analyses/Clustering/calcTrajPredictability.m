function [acc,sigMat,deltaPoint] = calcTrajPredictability(dataCell,varargin)
%quantifyInternalVariability.m Quantifies the variability due to internal
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

shouldShuffle = true;
oneClustering = false;
nShuffles = 500;
useBehavior = false;
shuffleInitial = false;
perc = 10;
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'shouldshuffle'
                shouldShuffle = varargin{argInd+1};
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
        end
    end
end

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%subset to 6-0 trials
dataCell = getTrials(dataCell,'maze.numLeft==0,6');

if useBehavior
    traces = catBinnedDataFrames(dataCell);
    keepVar = 2:6; %2 - xPos, 3 - yPos, 4 - view angle, 5 - xVel, 6 - yVel
    traces = traces(keepVar,:,:);
else
    %get traces
    [~,traces] = catBinnedTraces(dataCell);
end

%get nNeurons
nTrials = size(traces,3);

%%%%%%%%% Create matrix of values at each point in the maze

tracePoints = getMazePoints(traces,yPosBins);
nPoints = size(tracePoints,2);

%%%%%%%%%%%% cluster
if oneClustering
    reshapePoints = reshape(tracePoints,size(tracePoints,1),...
        size(tracePoints,2)*size(tracePoints,3));
    allClusterIDs = apClusterNeuronalStates(reshapePoints, perc);
    clusterIDs = reshape(allClusterIDs,size(tracePoints,3),size(tracePoints,2));
else
    clusterIDs = nan(nTrials,nPoints);
    for point = 1:nPoints
        clusterIDs(:,point) = apClusterNeuronalStates(squeeze(tracePoints(:,point,:)));
        if shuffleInitial
            clusterIDs(:,point) = shuffleArray(clusterIDs(:,point));
        end
    end
end

%%% get unique clusters 
uniqueClusters = cell(nPoints,1);
clusterCounts = cell(nPoints,1);
for point = 1:nPoints
    [uniqueClusters{point},clusterCounts{point}] = count_unique(clusterIDs(:,point));
end
nUnique = cellfun(@length,uniqueClusters);

%% calculate accuracy 
acc = getAccuracy(nPoints,nTrials,uniqueClusters,clusterIDs,nUnique);


%% shuffle 
shuffleAcc = nan(nPoints,nPoints,nShuffles);
for shuffleInd = 1:nShuffles
    shuffleClusters = clusterIDs;
    for point = 1:nPoints
        shuffleClusters(:,point) = shuffleArray(shuffleClusters(:,point));
    end
    shuffleAcc(:,:,shuffleInd) = getAccuracy(nPoints,nTrials,uniqueClusters,shuffleClusters,nUnique);
    dispProgress('Shuffling %d/%d',shuffleInd,shuffleInd,nShuffles);
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
pointDist = triu(squareform(pdist([1:nPoints]')));

%initialize 
meanAcc = nan(nPoints-1,1);
meanNSTD = nan(size(meanAcc));
meanSig = nan(size(meanAcc));
meanChance = nan(size(meanAcc));
chanceBounds = nan(nPoints-1,3,2);

% loop through each delta 
for deltaInd = 1:nPoints-1
    
    %get matchInd
    matchInd = pointDist == deltaInd;
    
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

function acc = getAccuracy(nPoints,nTrials,uniqueClusters,clusterIDs,nUnique)
acc = nan(nPoints);
for startPoint = 1:(nPoints-1)
    for endPoint = startPoint+1:nPoints
        
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
        acc(startPoint,endPoint) = 100*sum(trialCorrect)/nTrials;
    end
end
end




