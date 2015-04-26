function [meanDiffProb,sigMat] = quantifyInternalVariability(dataCell,varargin)
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
%
%ASM 4/15

shouldShuffle = true;
nShuffles = 200;
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

%get tracs
[~,traces] = catBinnedTraces(dataCell);

%get nNeurons
nTrials = size(traces,3);

%get mazePatterns
mazePatterns = getMazePatterns(dataCell);
nSeg = size(mazePatterns,2);

%%%%%%%%% Create matrix of values at each point in the maze

tracePoints = getMazePoints(traces,yPosBins);
nPoints = size(tracePoints,2);

%%%%%%%%%%%% cluster
clusterIDs = nan(nTrials,nPoints);
for point = 1:nPoints
    clusterIDs(:,point) = apClusterNeuronalStates(squeeze(tracePoints(:,point,:)));
end

%%%%%%%%%% calculate probabilities 
meanDiffProb = countPredictions(clusterIDs);

%%%%%% shuffle
if shouldShuffle 
    shuffleProb = nan(nPoints,nPoints,nShuffles);
    for shuffleInd = 1:nShuffles
        
        %shuffle clusterIDs
        shuffleIDs = nan(size(clusterIDs));
        for point = 1:nPoints
            shuffleIDs(:,point) = shuffleArray(clusterIDs(:,point));
        end       
        
        %get probabilities
        shuffleProb(:,:,shuffleInd) = countPredictions(shuffleIDs);
        
        %display progress
        dispProgress('Shuffling cluster labels %d/%d',shuffleInd,shuffleInd,nShuffles);
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
end

% function predMat = predictClusters(clusterIDs,leftTrials,rightTrials)
% %predictClusters.m Predicts future clusters given clusterIDs. Takes into
% %account left and right trials
% 
% %subset to left trials 
% leftMeanProbs 
% 
% end

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




