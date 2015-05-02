function [meanDiffProb,sigMat,deltaPoint] = quantifyBehavToNeuronalClusterProb(dataCell,varargin)
%quantifyBehavToNeuronalClusterProb.m Quantifies the mean absolute
%difference from the null probability for predciting the neuronal cluster
%ID based on the behavioral clusterID both at the current time and at
%future times
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUPUTS
%meanDiffProb - nPoints x nPoints array of mean difference from null
%   probabilities of predicting neuronal cluster based on behavior
%sigMat - nPoints x nPoints array of significance
%
%ASM 4/15

%% process arguments

shouldShuffle = true;
nShuffles = 500;
useBootstrapping = false;
nBootstrap = 100;
excludeTurn = false;
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
            case 'usebootstrapping'
                useBootstrapping = varargin{argInd+1};
            case 'nbootstrap'
                nBootstrap = varargin{argInd+1};
            case 'excludeturn'
                excludeTurn = varargin{argInd+1};
        end
    end
end

%% perform analysis


%get clusters
[behavClusterIDs,neurClusterIDs] = getClusters(dataCell);
if excludeTurn 
    behavClusterIDs = behavClusterIDs(:,1:8);
    neurClusterIDs = neurClusterIDs(:,1:8);
end
[nTrials,nPoints] = size(behavClusterIDs);

%%%%%%%%%% calculate probabilities
if useBootstrapping
    meanDiffProb = nan(nPoints,nPoints,nBootstrap);
    shuffleProb = nan(nPoints,nPoints,nShuffles,nBootstrap);
    for bootInd = 1:nBootstrap
        %display progress
        dispProgress('Bootstrapping %d/%d',bootInd,bootInd,nBootstrap);
        
        %select random trials
        randTrials = randsample(nTrials,nTrials,true);
        meanDiffProb(:,:,bootInd) = countPredictions(behavClusterIDs(randTrials,:),...
            neurClusterIDs(randTrials,:));
        
        %%%%%% shuffle
        if shouldShuffle
            parfor shuffleInd = 1:nShuffles
                
                %shuffle clusterIDs
                behavShuffleIDs = nan(nTrials,nPoints);
                neurShuffleIDs = nan(nTrials,nPoints);
                for point = 1:nPoints
                    behavShuffleIDs(:,point) = shuffleArray(behavClusterIDs(randTrials,point)); %#ok<*PFBNS>
                    neurShuffleIDs(:,point) = shuffleArray(neurClusterIDs(randTrials,point));
                end
                
                %get probabilities
                shuffleProb(:,:,shuffleInd,bootInd) = countPredictions(behavShuffleIDs,...
                    neurClusterIDs);
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
    end
else
    meanDiffProb = countPredictions(behavClusterIDs,neurClusterIDs);
    
    %%%%%% shuffle
    if shouldShuffle
        shuffleProb = nan(nPoints,nPoints,nShuffles);
        for shuffleInd = 1:nShuffles
            
            %shuffle clusterIDs
            behavhuffleIDs = nan(size(behavClusterIDs));
            for point = 1:nPoints
                behavhuffleIDs(:,point) = shuffleArray(behavClusterIDs(:,point));
            end
            
            %get probabilities
            shuffleProb(:,:,shuffleInd) = countPredictions(behavhuffleIDs,neurClusterIDs);
            
            %display progress
            dispProgress('Shuffling cluster labels %d/%d',shuffleInd,shuffleInd,nShuffles);
        end
        
    end
    
    %calculate significance
    p95Bound = prctile(shuffleProb,[2.5 97.5],3);
    p99Bound = prctile(shuffleProb,[0.5 99.5],3);
    p999Bound = prctile(shuffleProb,[0.05 99.95],3);
    
    sigMat = zeros(nPoints);
    for bootInd = 1:size(meanDiffProb,3)
        sigMat(meanDiffProb(:,:,bootInd) > p95Bound(:,:,2)) = 1;
        sigMat(meanDiffProb(:,:,bootInd) > p99Bound(:,:,2)) = 2;
        sigMat(meanDiffProb(:,:,bootInd) > p999Bound(:,:,2)) = 3;
    end
end

%% calculate deltaPoint for out
if nargout < 3
    return;
end

assignin('base','meanDiffProb',meanDiffProb);
assignin('base','shuffleProb',shuffleProb);
assignin('base','nPoints',nPoints);


%get distance matrix
pointDist = triu(squareform(pdist([1:nPoints]')));

%loop through each deltapoint
meanProbDelta = nan(nPoints,size(meanDiffProb,3));

meanProbDeltaSig = nan(nPoints,size(meanDiffProb,3));
nSTDAboveMedian = nan(nPoints,size(meanDiffProb,3));
for delta = 0:(nPoints-1)
    
    %get matchInd
    if delta > 0
        matchInd = pointDist == delta;
    else
        matchInd = sub2ind([nPoints nPoints],1:nPoints,1:nPoints);
    end
    
    %sum meanDiffProb
    for bootInd = 1:size(meanDiffProb,3);
        tempDiffProb = meanDiffProb(:,:,bootInd);
        meanProbDelta(delta+1,bootInd) = median(tempDiffProb(matchInd));
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
        
        if meanProbDelta(delta+1,bootInd) > p95BoundDelta(2)
            meanProbDeltaSig(delta+1,bootInd) = 1;
        end
        if meanProbDelta(delta+1,bootInd) > p99BoundDelta(2)
            meanProbDeltaSig(delta+1,bootInd) = 2;
        end
        if meanProbDelta(delta+1,bootInd) > p999BoundDelta(2)
            meanProbDeltaSig(delta+1,bootInd) = 3;
        end
        
        %get std of shuffle
        shuffleSTD = std(shuffleMeanProbDelta(:,bootInd));
        shuffleMedian = median(shuffleMeanProbDelta(:,bootInd));
        
        %get nstd above median
        nSTDAboveMedian(delta+1,bootInd) = (meanProbDelta(delta+1,bootInd)...
            - shuffleMedian)/shuffleSTD;
    end
end

deltaPoint.meanProb = mean(meanProbDelta,2);
deltaPoint.sig = mode(meanProbDeltaSig,2);
deltaPoint.nSTDAboveMedian = mean(nSTDAboveMedian,2);
deltaPoint.allMeanProb = meanProbDelta;
deltaPoint.allSig = meanProbDeltaSig;
deltaPoint.allNSTDAboveMedian = nSTDAboveMedian;


end

function meanDiffProb = countPredictions(behavClusters,neuroClusters)

%get nPoints
[nTrials,nPoints] = size(behavClusters);

%initialize
meanDiffProb = nan(nPoints);

% loop through each starting point
for startPoint = 1:nPoints
    for endPoint = startPoint:nPoints
        
        %get current unique behavior clusters
        [currUnique,currCount] = count_unique(behavClusters(:,startPoint));
        currFrac = currCount/nTrials;
        
        %loop through each current unique behavior cluster and calculate the
        %difference between the probability of moving to a given neuronal cluster
        %and the null probability
        [nextUnique,nextCount] = count_unique(neuroClusters(:,endPoint));
        nullProb = nextCount/nTrials;
        diffProb = [];
        weights = [];
        for currCluster = 1:length(currUnique) %for each current cluster
            %get a list of neuronal clusters at endPoint with the current
            %behavioral cluster
            currNextClusters = neuroClusters(behavClusters(:,startPoint) == ...
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

function [behavClusterIDs,neurClusterIDs] = getClusters(dataCell)
%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%get behavioral traces
behavTraces = catBinnedDataFrames(dataCell);
keepVar = 2:6; %2 - xPos, 3 - yPos, 4 - view angle, 5 - xVel, 6 - yVel
behavTraces = behavTraces(keepVar,:,:);

%get neuronal traces
[~,neuronalTraces] = catBinnedTraces(dataCell);

%get nNeurons
nTrials = size(neuronalTraces,3);

%%%%%%%%% Create matrix of values at each point in the maze

neuronalTracePoints = getMazePoints(neuronalTraces,yPosBins);
behavTracePoints = getMazePoints(behavTraces,yPosBins);
nPoints = size(neuronalTracePoints,2);

%%%%%%%%%%%% cluster
behavClusterIDs = nan(nTrials,nPoints);
neurClusterIDs = nan(nTrials,nPoints);
for point = 1:nPoints
    behavClusterIDs(:,point) = apClusterNeuronalStates(squeeze(behavTracePoints(:,point,:)));
    neurClusterIDs(:,point) = apClusterNeuronalStates(squeeze(neuronalTracePoints(:,point,:)));
end
end