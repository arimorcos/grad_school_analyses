function [RL, LL, LR, RR] = findHistoryPairs(mazePatterns,segNum)
%findHistoryTriplets.m Finds triplets for history analysis at the given
%segment number
%
%INPUTS
%mazePatterns - nTrials x nSeg array of mazePatterns
%segNum - segment number to analyze at. Must be greater than or equal to 3.
%
%OUTPUTS
%RL - array of trial indices matching RL
%LL - array of trial indices matching LL
%RR - array of trial indices matching RR
%LR - array of trial indices matching LR
%
%ASM 4/15

%check inputs
nSeg = size(mazePatterns,2);
assert(segNum >= 3 & segNum <= nSeg,'segNum must be between 3 and %d. Current value: %d',nSeg,segNum);

%get net evidence
netEvidence = getNetEvidence(mazePatterns);

%find match trials
allRL = mazePatterns(:,segNum-1) == 0 &... %seg 1 - R
    mazePatterns(:,segNum) == 1; %seg 2 - L

allLL = mazePatterns(:,segNum-1) == 1 &... %seg 2 - L
    mazePatterns(:,segNum) == 1; %seg 3 - L

allRR = mazePatterns(:,segNum-1) == 0 &... %seg 2 - R
    mazePatterns(:,segNum) == 0; %seg 3 - R

allLR = mazePatterns(:,segNum-1) == 1 &... %seg 2 - L
    mazePatterns(:,segNum) == 0; %seg 3 - R

%evenly distribute net evidence
%get net evidence at current segment
netEv = netEvidence(:,segNum);

%find unique positive values
uniqueNetEv = unique(netEv);

%initialize
RL = cell(length(uniqueNetEv),1);
LL = cell(size(RL));
RR = cell(size(RL));
LR = cell(size(RL));

%loop through
for evInd = 1:length(uniqueNetEv)
    
    %left trials
    RL{evInd} = find(allRL & netEv == uniqueNetEv(evInd));
    LL{evInd} = find(allLL & netEv == uniqueNetEv(evInd));
    
    %right trials
    RR{evInd} = find(allRR & netEv == uniqueNetEv(evInd));
    LR{evInd} = find(allLR & netEv == uniqueNetEv(evInd));
    
end

%remove zeroInd 
nonzeroL = ~cellfun(@isempty,LL) & ~cellfun(@isempty,RL);
nonzeroR = ~cellfun(@isempty,LR) & ~cellfun(@isempty,RR);
LL = LL(nonzeroL);
RL = RL(nonzeroL);
RR = RR(nonzeroR);
LR = LR(nonzeroR);


%get difference in numbers 
combL = cat(2,cellfun(@length,LL),cellfun(@length,RL));
combR = cat(2,cellfun(@length,LR),cellfun(@length,RR));

%find minimum difference 
if size(combL,1) > 1 
    minCountL = min(combL,[],2);
    [~,indL] = max(minCountL);
else
    indL = 1;
end
if size(combR,1) > 1 
    minCountR = min(combR,[],2);
    [~,indR] = max(minCountR);
else 
    indR = 1;
end

%return minimum difference 
LL = LL{indL};
RL = RL{indL};
LR = LR{indR};
RR = RR{indR};
end