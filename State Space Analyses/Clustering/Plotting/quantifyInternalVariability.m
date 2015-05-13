function [meanDiffProb,sigMat,deltaPoint] = quantifyInternalVariability(dataCell,varargin)
%quantifyInternalVariability.m Quantifies the variability due to internal
%at each segment. Asks given knowledge of the current cluster, can you
%predict the the next cluster? What about the n+2 cluster?
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%
%OUTPUTS
%meanDiffProb - nPoints x nPoints array of mean absolute difference from
%   null probability
%sigMat - nPoints x nPoints array of significance. 0 - not significant, 1 -
%   p < 0.05, 2 - p < 0.01, 3 - p < 0.001
%deltaPoint - structure with two fields:
%    summedProb - 1 x nPoints - 1 array of mean absolute difference
%    sig - 1 x nPoints - 1 array of significance in same format
%
%ASM 4/15

shouldShuffle = true;
nShuffles = 500;
useBehavior = false;
useBootstrapping = false;
nBootstrap = 100;
excludeTurn = false;
shuffleInitial = false;
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
            case 'usebootstrapping'
                useBootstrapping = varargin{argInd+1};
            case 'nbootstrap'
                nBootstrap = varargin{argInd+1};
            case 'excludeturn'
                excludeTurn = varargin{argInd+1};
            case 'shuffleinitial'
                shuffleInitial = varargin{argInd+1};
        end
    end
end

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%subset to 6-0 trials
dataCell = getTrials(dataCell,'maze.numLeft==0,6');

%get left and right trial indices
leftTrials = getCellVals(dataCell,'maze.leftTrial');
rightTrials = ~leftTrials;

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

%get mazePatterns
mazePatterns = getMazePatterns(dataCell);

%%%%%%%%% Create matrix of values at each point in the maze

tracePoints = getMazePoints(traces,yPosBins);
nPoints = size(tracePoints,2);

%%%%%%%%%%%% cluster
clusterIDs = nan(nTrials,nPoints);
for point = 1:nPoints
    clusterIDs(:,point) = apClusterNeuronalStates(squeeze(tracePoints(:,point,:)));
    if shuffleInitial
        clusterIDs(:,point) = shuffleArray(clusterIDs(:,point));
    end
end

if excludeTurn
    clusterIDs = clusterIDs(:,1:8);
    nPoints = 8;
end

%%%%%%%%%% calculate probabilities
if useBootstrapping
    meanDiffProb = nan(nPoints,nPoints,nBootstrap);
    shuffleProb = nan(nPoints,nPoints,nShuffles,nBootstrap);
    nSTDAboveMedian = nan(size(meanDiffProb));
    for bootInd = 1:nBootstrap
        %display progress
        dispProgress('Bootstrapping %d/%d',bootInd,bootInd,nBootstrap);
        
        %select random trials
        randTrials = randsample(nTrials,nTrials,true);
        meanDiffProb(:,:,bootInd) = countPredictions(clusterIDs(randTrials,:));
        
        %%%%%% shuffle
        if shouldShuffle
            parfor shuffleInd = 1:nShuffles
                
                %shuffle clusterIDs
                shuffleIDs = nan(size(clusterIDs));
                for point = 1:nPoints
                    shuffleIDs(:,point) = shuffleArray(clusterIDs(:,point));
                end
                
                %get probabilities
                shuffleProb(:,:,shuffleInd,bootInd) = countPredictions(shuffleIDs(randTrials,:));
            end
            
        end
        
        %calculate significance
        p95Bound = prctile(shuffleProb(:,:,:,bootInd),[2.5 97.5],3);
        p99Bound = prctile(shuffleProb(:,:,:,bootInd),[0.5 99.5],3);
        p999Bound = prctile(shuffleProb(:,:,:,bootInd),[0.05 99.95],3);
        
        sigMat = zeros(nPoints);
        sigMat(meanDiffProb(:,:,bootInd) > p95Bound(:,:,2)) = 1;
        sigMat(meanDiffProb(:,:,bootInd) > p99Bound(:,:,2)) = 2;
        sigMat(meanDiffProb(:,:,bootInd) > p999Bound(:,:,2)) = 3;
        
        %get std and median
        stdShuffle = std(shuffleProb(:,:,:,bootInd),0,3);
        medianShuffle = median(shuffleProb(:,:,:,bootInd),3);
        
        %get nSTD
        nSTDAboveMedian(:,:,bootInd) = (meanDiffProb(:,:,bootInd) - medianShuffle)./stdShuffle;
    end
else
    meanDiffProb = countPredictions(clusterIDs);
    
    %%%%%% shuffle
    if shouldShuffle
        shuffleProb = nan(nPoints,nPoints,nShuffles);
        parfor shuffleInd = 1:nShuffles
            
            %shuffle clusterIDs
            shuffleIDs = nan(size(clusterIDs));
            for point = 1:nPoints
                shuffleIDs(:,point) = shuffleArray(clusterIDs(:,point));
            end
            
            %get probabilities
            shuffleProb(:,:,shuffleInd) = countPredictions(shuffleIDs);
            
            %display progress
%             dispProgress('Shuffling cluster labels %d/%d',shuffleInd,shuffleInd,nShuffles);
        end
        
    end
    
    %calculate significance
    p95Bound = prctile(shuffleProb,[2.5 97.5],3);
    p99Bound = prctile(shuffleProb,[0.5 99.5],3);
    p999Bound = prctile(shuffleProb,[0.05 99.95],3);
    
    sigMat = zeros(nPoints);
    sigMat(meanDiffProb > p95Bound(:,:,2)) = 1;
    sigMat(meanDiffProb > p99Bound(:,:,2)) = 2;
    sigMat(meanDiffProb > p999Bound(:,:,2)) = 3;
    
    %get std and median
    stdShuffle = std(shuffleProb,0,3);
    medianShuffle = median(shuffleProb,3);
    
    %get nSTD
    nSTDAboveMedian = (meanDiffProb - medianShuffle)./stdShuffle;
end

%% calculate deltaPoint for out
if nargout < 3
    return;
end

%get distance matrix
pointDist = triu(squareform(pdist([1:nPoints]')));

%loop through each deltapoint
meanProbDelta = nan(nPoints-1,size(meanDiffProb,3));

meanProbDeltaSig = nan(nPoints-1,size(meanDiffProb,3));
meanNSTDAboveMedian = nan(nPoints-1,size(meanDiffProb,3));
totalNSTDAboveMedian = nan(nPoints-1,size(meanDiffProb,3));
for delta = 1:(nPoints-1)
    
    %get matchInd
    matchInd = pointDist == delta;
    
    %sum meanDiffProb
    for bootInd = 1:size(meanDiffProb,3);
        tempDiffProb = meanDiffProb(:,:,bootInd);
        meanProbDelta(delta,bootInd) = nanmean(tempDiffProb(matchInd));
        tempNSTD = nSTDAboveMedian(:,:,bootInd);
        meanNSTDAboveMedian(delta,bootInd) = nanmean(tempNSTD(matchInd));
    end
    
    %check shuffles
    shuffleMeanProbDelta = zeros(nShuffles,size(meanDiffProb,3));
    for bootInd = 1:size(meanDiffProb,3)
        for shuffleInd = 1:nShuffles
            tempShuffle = shuffleProb(:,:,shuffleInd,bootInd);
            shuffleMeanProbDelta(shuffleInd,bootInd) = median(tempShuffle(matchInd));
        end
        
        %calculate significance
        p95BoundDelta = prctile(shuffleMeanProbDelta(:,bootInd),[2.5 97.5]);
        p99BoundDelta = prctile(shuffleMeanProbDelta(:,bootInd),[0.5 99.5]);
        p999BoundDelta = prctile(shuffleMeanProbDelta(:,bootInd),[0.05 99.95]);
        
        if meanProbDelta(delta,bootInd) > p95BoundDelta(2)
            meanProbDeltaSig(delta,bootInd) = 1;
        end
        if meanProbDelta(delta,bootInd) > p99BoundDelta(2)
            meanProbDeltaSig(delta,bootInd) = 2;
        end
        if meanProbDelta(delta,bootInd) > p999BoundDelta(2)
            meanProbDeltaSig(delta,bootInd) = 3;
        end
        
        %get std of shuffle
        shuffleSTD = std(shuffleMeanProbDelta(:,bootInd));
        shuffleMedian = median(shuffleMeanProbDelta(:,bootInd));
        
        %get nSTD above shuffle
        totalNSTDAboveMedian(delta,bootInd) = (meanProbDelta(delta,bootInd)...
            - shuffleMedian)/shuffleSTD;
    end
    
end

deltaPoint.meanProb = mean(meanProbDelta,2);
deltaPoint.sig = mode(meanProbDeltaSig,2);
deltaPoint.nSTDAboveMedian = mean(meanNSTDAboveMedian,2);
deltaPoint.totalNSTDAboveMedian = mean(totalNSTDAboveMedian,2);
deltaPoint.allMeanProb = meanProbDelta;
deltaPoint.allSig = meanProbDeltaSig;
deltaPoint.allTotalNSTDAboveMedian = totalNSTDAboveMedian;
deltaPoint.allNSTDAboveMedian = meanNSTDAboveMedian;
deltaPoint.fullMat.nSTDAboveMedian = nSTDAboveMedian;
deltaPoint.fullMat.meanDiffProb = meanDiffProb;
end

function meanDiffProb = countPredictions(clusterIDs)

%get nPoints
nPoints = size(clusterIDs,2);

%initialize
meanDiffProb = nan(nPoints);

%get unique clusters
uniqueClusters = arrayfun(@(x) unique(clusterIDs(:,x)),1:nPoints,'UniformOutput',false);

% loop through each starting point
for startPoint = 1:nPoints
    for endPoint = startPoint+1:nPoints
        
        %get current unique clusters
        [currUnique,currCount] = count_unique(clusterIDs(:,startPoint));
        currFrac = currCount/size(clusterIDs,1);
        
        %loop through each current unique cluster and calculate the
        %difference between the probability of moving to the next cluster
        %and the null probability
        [nextUnique,nextCount] = count_unique(clusterIDs(:,endPoint));
        nullProb = nextCount/size(clusterIDs,1);
        diffProb = [];
        weights = [];
        for currCluster = 1:length(currUnique) %for each current cluster
            %get matching nextClusters
            currNextClusters = clusterIDs(clusterIDs(:,startPoint) == ...
                currUnique(currCluster),endPoint);
            
            %get unique counts
            [uniqueCurrNextClusters,counts] = count_unique(currNextClusters);
            
            %pad counts with zeros to the length(nextUnique)
            countProb = zeros(length(nextUnique),1);
            countProb(ismember(nextUnique,uniqueCurrNextClusters)) = counts/length(currNextClusters);
            
            %get difference between count probabilities and null
            %probability
            diffProb = cat(1,diffProb,abs(countProb - nullProb));
            weights = cat(1,weights,repmat(currFrac(currCluster),length(countProb),1));
            
        end
        
        %store
        meanDiffProb(startPoint,endPoint) = weights'*diffProb;
        
    end
end

end




