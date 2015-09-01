function out = predictClusterInternalExternal(clusterIDs,imTrials)
%predictClusterInternalExternal.m In a leave-one out fashion, predicts the
%upcoming cluster using a) no information (which cluster is most likely),
%b) just the marginal segment, given the same net evidence (equivalent to
%pure external), c) just the previous cluster (equivalent to pure
%internal), and d) both the marginal segment and the previous cluster
%
%INPPUTS
%clusterIDs - clusterIDs
%imTrials - array of trials
%
%OUTPUTS
%out - structure containing:
%   noInformationAcc - 1 x nSeg array of accuracy given no information
%   externalAcc - 1 x nSeg array of accuracy given only external cue
%   internalAcc - 1 x nSeg array of accuracy given only internal state
%   bothAcc - 1 x nSeg array of accuracy given both internal and external cue
%
%ASM 8/15

nBootstrap = 100;

%assert proper clustering
nTrials = length(imTrials);
assert(size(clusterIDs,1) == nTrials,'clusterIDs must have the same number of trials');

%get maze patterns 
mazePatterns = getMazePatterns(imTrials);
netEv = getNetEvidence(imTrials);
netEv = cat(2,zeros(nTrials,1),netEv(:,1:end-1));
nSeg = size(mazePatterns,2);

%loop through each trial 
correctCluster = nan(nTrials,nSeg);
noInformationGuess = nan(nTrials,nSeg,nBootstrap);
externalGuess = nan(nTrials,nSeg,nBootstrap);
internalGuess = nan(nTrials,nSeg,nBootstrap);
bothGuess = nan(nTrials,nSeg,nBootstrap);
for trialInd = 1:nTrials
    
    %get test trials 
    testTrials = setdiff(1:nTrials,trialInd);
    
    %display progress
    dispProgress('Processing trial %d/%d',trialInd,trialInd,nTrials);
    
    %loop through nSeg 
    for segInd = 1:nSeg
        
        %get actual answer 
        correctCluster(trialInd,segInd) = clusterIDs(trialInd,segInd+1);
        
        %%%%% get trial indices for each %%%% 
        
        %get current seg
        currSeg = mazePatterns(trialInd,segInd);
        currNetEv = netEv(trialInd,segInd);
        
        %find testTrials which match current seg 
        currSegTrials = testTrials(mazePatterns(testTrials,segInd) == currSeg & ...
            netEv(testTrials,segInd) == currNetEv);
        
        %get current cluster 
        currCluster = clusterIDs(trialInd,segInd);
        
        %find testTrials which match current cluster 
%         currClusterTrials = testTrials(clusterIDs(testTrials,segInd) == currCluster);
        currClusterTrials = testTrials(clusterIDs(testTrials,segInd) == currCluster & ...
            netEv(testTrials,segInd) == currNetEv);
        
        % find testTrials which match current cluster and current segment 
        bothCurrSegCurrClusterTrials = intersect(currClusterTrials, currSegTrials);
        
        %%%%% find minimum number of trials %%%%%% 
        nTest = length(testTrials);
        nExternal = length(currSegTrials);
        nInternal = length(currClusterTrials);
        nBoth = length(bothCurrSegCurrClusterTrials);
        
        minTrials = min(cat(1,nTest,nExternal,nInternal,nBoth));

        
        %%%%% get actual guesses by bootstrapping %%%%%%%%%%%
        
        for bootInd = 1:nBootstrap
            %get random guess
            bootTest = randsample(testTrials,minTrials);
            noInformationGuess(trialInd,segInd,bootInd) = mode(clusterIDs(bootTest,segInd+1));
            
            %get external guess
            bootExternal = randsample(currSegTrials,minTrials);
            externalGuess(trialInd,segInd,bootInd) = mode(clusterIDs(bootExternal,segInd+1));
            
            % get internal guess
            bootInternal = randsample(currClusterTrials,minTrials);
            internalGuess(trialInd,segInd,bootInd) = mode(clusterIDs(bootInternal,segInd+1));
            
            % get both guess
            bootBoth = randsample(bothCurrSegCurrClusterTrials,minTrials);
            bothGuess(trialInd,segInd,bootInd) = mode(clusterIDs(bootBoth,segInd+1));
        end
    end
    
end

%get accuracy for each 
out.noInformationAcc = mean(sum(bsxfun(@eq,noInformationGuess,correctCluster))/nTrials,3);
out.externalAcc = mean(sum(bsxfun(@eq,externalGuess,correctCluster))/nTrials,3);
out.internalAcc = mean(sum(bsxfun(@eq,internalGuess,correctCluster))/nTrials,3);
out.bothAcc = mean(sum(bsxfun(@eq,bothGuess,correctCluster))/nTrials,3);
