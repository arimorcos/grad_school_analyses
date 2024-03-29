function [accuracy, shuffleAccuracy, nSTD, trialInfo] = ...
    predictHistoryFromClusters(clusterIDs,dataCell,nShuffles)
%predictHistoryFromClusters.m Predcits segment history based on current
%cluster in a leave-one-out fashion
%
%INPUTS
%clusterIDs - cluster labels 
%dataCell -dataCell cluster information was generated from 
%
%OUTPUTS
%accuracy - scalar accuracy as fraction of 1 
%shuffleAccuracy - nShuffles x 1 array of shuffle accuracy 
%nSTD - number of standard deviations above shuffle
%trialInfo - structure containing:
%   guess - array of guesses
%   real - array of actual answers 
%   whichTrials - trial indices used in guess and real
%   whichSeg - segments used from each trial
%
%ASM 7/15

%get real accuracy 
[accuracy, trialInfo] = getHistoryClusterAcc(clusterIDs,dataCell);

%get shuffled accuracy 
if nargin < 3 || isempty(nShuffles)
    nShuffles = 1000;
end

shuffleAccuracy = nan(nShuffles,1);
for shuffleInd = 1:nShuffles
    %shuffle clusterIDs 
    shuffleIDs = nan(size(clusterIDs));
    for point = 1:size(clusterIDs,2)
        shuffleIDs(:,point) = shuffleArray(clusterIDs(:,point));
    end
    
    shuffleAccuracy(shuffleInd) = getHistoryClusterAcc(shuffleIDs,dataCell);
    
    %display progress
    dispProgress('Shuffling history %d/%d',shuffleInd,shuffleInd,nShuffles);
end

%calculate nSTD 
nSTD = (accuracy - median(shuffleAccuracy))/std(shuffleAccuracy);

end 

function [accuracy, trialInfo] = getHistoryClusterAcc(clusterIDs,dataCell)
trialMatch = true;

%initialize
totalNClusters = 0;
actualAnswer = [];
guessedAnswer = [];
whichTrials = [];
whichSeg = [];

%loop through each segment and get accuracy
for segNum = 3:6
    
    %get tempClusterIDs
    tempClusterIDs = clusterIDs(:,segNum+1);
    
    %convert clusterIDs to 1:nClusters
    uniqueClusters = unique(tempClusterIDs);
    nClusters = length(uniqueClusters);
    oldClusterIDs = tempClusterIDs;
    for clusterInd = 1:nClusters
        tempClusterIDs(oldClusterIDs==uniqueClusters(clusterInd)) = ...
            clusterInd + totalNClusters;
    end
    totalNClusters = totalNClusters + nClusters;
    
    %get mazePatterns
    mazePatterns = getMazePatterns(dataCell);
    
    %find match trials
    [LRLTrials, RLLTrials, RLRTrials, LRRTrials] = ...
        findHistoryPairs(mazePatterns,segNum);
    
    %ensure trial match
    if trialMatch
        LRLTrials = LRLTrials(1:min(length(LRLTrials),length(RLLTrials)));
        RLLTrials = RLLTrials(1:min(length(LRLTrials),length(RLLTrials)));
        LRRTrials = LRRTrials(1:min(length(LRRTrials),length(RLRTrials)));
        RLRTrials = RLRTrials(1:min(length(LRRTrials),length(RLRTrials)));
    end
    
    %get guesses for left
    allLeft = cat(1,LRLTrials,RLLTrials);
    nLeft = length(allLeft);
    for leftTrial = 1:nLeft
        
        %get the actual answer 
        actualAnswer = cat(1,actualAnswer,ismember(allLeft(leftTrial),LRLTrials));
        
        %guess an answer 
        trialCluster = clusterIDs(allLeft(leftTrial),segNum+1);
        allMatchingTrials = find(clusterIDs(:,segNum+1) == trialCluster);
        leftTripletMatchTrials = allMatchingTrials(ismember(allMatchingTrials,allLeft));
        leftTripletMatchTrials =  leftTripletMatchTrials(leftTripletMatchTrials ~= allLeft(leftTrial));
        if sum(ismember(leftTripletMatchTrials,LRLTrials)) > sum(ismember(leftTripletMatchTrials,RLLTrials))
            guessedAnswer = cat(1,guessedAnswer,1);
        elseif sum(ismember(leftTripletMatchTrials,RLLTrials)) > sum(ismember(leftTripletMatchTrials,LRLTrials))
            guessedAnswer = cat(1,guessedAnswer,0);
        else
            guessedAnswer = cat(1,guessedAnswer,randi([0 1]));
        end
        
    end
    
    %get guesses for right 
    allRight = cat(1,LRRTrials,RLRTrials);
    nRight = length(allRight);
    for rightTrial = 1:nRight
        
        %get the actual answer 
        actualAnswer = cat(1,actualAnswer,ismember(allRight(rightTrial),LRRTrials));
        
        %guess an answer 
        trialCluster = clusterIDs(allRight(rightTrial),segNum+1);
        allMatchingTrials = find(clusterIDs(:,segNum+1) == trialCluster);
        rightTripletMatchTrials = allMatchingTrials(ismember(allMatchingTrials,allRight));
        rightTripletMatchTrials =  rightTripletMatchTrials(rightTripletMatchTrials ~= allRight(rightTrial)); %remove current trial
        if sum(ismember(rightTripletMatchTrials,LRRTrials)) > sum(ismember(rightTripletMatchTrials,RLRTrials))
            guessedAnswer = cat(1,guessedAnswer,1);
        elseif sum(ismember(rightTripletMatchTrials,RLRTrials)) > sum(ismember(rightTripletMatchTrials,LRRTrials))
            guessedAnswer = cat(1,guessedAnswer,0);
        else
            guessedAnswer = cat(1,guessedAnswer,randi([0 1]));
        end
        
    end
    whichTrials = cat(1,whichTrials,allLeft,allRight);
    whichSeg = cat(1,whichSeg,repmat(segNum,length(allLeft)+length(allRight),1));
end

%get accuracy 
accuracy = sum(actualAnswer == guessedAnswer)/length(actualAnswer);
trialInfo.guess = guessedAnswer;
trialInfo.real = actualAnswer;
trialInfo.whichTrials = whichTrials;
trialInfo.whichSeg = whichSeg;

end