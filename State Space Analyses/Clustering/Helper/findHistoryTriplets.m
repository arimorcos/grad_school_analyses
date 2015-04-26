function [LRL, RLL, RLR, LRR] = findHistoryTriplets(mazePatterns,segNum)
%findHistoryTriplets.m Finds triplets for history analysis at the given
%segment number 
%
%INPUTS
%mazePatterns - nTrials x nSeg array of mazePatterns 
%segNum - segment number to analyze at. Must be greater than or equal to 3.
%
%OUTPUTS
%LRL - array of trial indices matching LRL
%RLL - array of trial indices matching RLL
%LRR - array of trial indices matching LRR
%RLR - array of trial indices matching RLR
%
%ASM 4/15

%check inputs 
nSeg = size(mazePatterns,2);
assert(segNum >= 3 & segNum <= nSeg,'segNum must be between 3 and %d. Current value: %d',nSeg,segNum);

%get net evidence 
netEvidence = getNetEvidence(mazePatterns);

%find match trials 
allLRL = mazePatterns(:,segNum-2) == 1 &... %seg 1 - L
    mazePatterns(:,segNum-1) == 0 &... %seg 2 - R
    mazePatterns(:,segNum) == 1; %seg 3 - L

allRLL = mazePatterns(:,segNum-2) == 0 &... %seg 1 - R
    mazePatterns(:,segNum-1) == 1 &... %seg 2 - L
    mazePatterns(:,segNum) == 1; %seg 3 - L

allLRR = mazePatterns(:,segNum-2) == 1 &... %seg 1 - L
    mazePatterns(:,segNum-1) == 0 &... %seg 2 - R
    mazePatterns(:,segNum) == 0; %seg 3 - R

allRLR = mazePatterns(:,segNum-2) == 0 &... %seg 1 - R
    mazePatterns(:,segNum-1) == 1 &... %seg 2 - L
    mazePatterns(:,segNum) == 0; %seg 3 - R

%evenly distribute net evidence
if segNum >= 4 
    %get net evidence at segment before triplet 
    netEv = netEvidence(:,segNum-3); 
    
    %find unique positive values 
    uniqueNetEv = unique(abs(netEv));
    
    %initialize 
    LRL = [];
    RLL = [];
    LRR = [];
    RLR = [];    
    
    %loop through 
    for evInd = 1:length(uniqueNetEv)
        
        %left trials 
        LRL = cat(1,LRL,evenlyDistribute(allLRL, netEv, uniqueNetEv(evInd)));
        RLL = cat(1,RLL,evenlyDistribute(allRLL, netEv, uniqueNetEv(evInd)));
        
        %right trials 
        LRR = cat(1,LRR,evenlyDistribute(allLRR, netEv, uniqueNetEv(evInd)));
        RLR = cat(1,RLR,evenlyDistribute(allRLR, netEv, uniqueNetEv(evInd)));
        
    end
    
else
    LRL = find(allLRL);
    RLL = find(allRLL);
    LRR = find(allLRR);
    RLR = find(allRLR);
end
end

function out = evenlyDistribute(trialInd, netEvArray, testEv)

%return all if 0 
if testEv == 0 
    out = find(trialInd);
    return;
end

%get indices which both match test evidence and trialInd
pos = find(trialInd & netEvArray == testEv);
neg = find(trialInd & netEvArray == -1*testEv);

%get length of both 
nPos = length(pos);
nNeg = length(neg);

%sample one or the other 
if nPos > nNeg
    out = cat(1,neg,randsample(pos,nNeg));
elseif nNeg > nPos
    out = cat(1,pos,randsample(neg,nPos));
elseif nNeg == nPos
    out = cat(1,pos,neg);
end

end