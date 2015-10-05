function [accuracy, shuffleAccuracy, nSTD, trialInfo] = ...
    predictHistoryFromClustersSeparateClustering(dataCell,nShuffles)
%predictHistoryFromClustersSeparateClustering.m Predcits segment history based on current
%cluster in a leave-one-out fashion.Performs clustering separately for each
%trial combination
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
[accuracy, trialInfo] = getHistoryClusterAcc(dataCell,false);

%get shuffled accuracy 
if nargin < 3 || isempty(nShuffles)
    nShuffles = 1000;
end

shuffleAccuracy = nan(nShuffles,1);
for shuffleInd = 1:nShuffles
    
    shuffleAccuracy(shuffleInd) = getHistoryClusterAcc(dataCell,true);
    
    %display progress
    dispProgress('Shuffling history %d/%d',shuffleInd,shuffleInd,nShuffles);
end

%calculate nSTD 
nSTD = (accuracy - median(shuffleAccuracy))/std(shuffleAccuracy);

end 

function [accuracy, trialInfo] = getHistoryClusterAcc(dataCell,shouldShuffle)
trialMatch = true;

%initialize
perc = 10;
totalNClusters = 0;
actualAnswer = [];
guessedAnswer = [];
whichTrials = [];
whichSeg = [];

traces = catBinnedDeconvTraces(dataCell);
tracePoints = getMazePoints(traces,dataCell{1}.imaging.yPosBins);

%loop through each segment and get accuracy
for segNum = 3:6
    
%     %get tempClusterIDs
%     tempClusterIDs = clusterIDs(:,segNum+1);
%     
%     %convert clusterIDs to 1:nClusters
%     uniqueClusters = unique(tempClusterIDs);
%     nClusters = length(uniqueClusters);
%     oldClusterIDs = tempClusterIDs;
%     for clusterInd = 1:nClusters
%         tempClusterIDs(oldClusterIDs==uniqueClusters(clusterInd)) = ...
%             clusterInd + totalNClusters;
%     end
    
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
        
        %cluster 
        clusterIDsLeft = apClusterNeuronalStates(...
            squeeze(tracePoints(:,segNum+1,allLeft)), perc);
        
        if shouldShuffle
            clusterIDsLeft = shuffleArray(clusterIDsLeft);
        end
        
        %guess an answer 
        trialCluster = clusterIDsLeft(leftTrial);
        leftTripletMatchTrials = find(clusterIDsLeft == trialCluster);
        leftTripletMatchTrials =  leftTripletMatchTrials(leftTripletMatchTrials ~= leftTrial);
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
        
        %cluster 
        clusterIDsRight = apClusterNeuronalStates(...
            squeeze(tracePoints(:,segNum+1,allRight)), perc);
        
        if shouldShuffle
            clusterIDsRight = shuffleArray(clusterIDsRight);
        end
        
        %guess an answer 
        trialCluster = clusterIDsRight(rightTrial);
        rightTripletMatchTrials = find(clusterIDsRight == trialCluster);
        rightTripletMatchTrials =  rightTripletMatchTrials(rightTripletMatchTrials ~= rightTrial);
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