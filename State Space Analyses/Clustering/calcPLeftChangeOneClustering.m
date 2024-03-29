function [deltaPLeft, startPLeft, startNetEv] = ...
    calcPLeftChangeOneClustering(clusterIDs,leftTurns,varargin)
%calcPLeftChangeOneClustering.m Calculates the change in p(leftTurn) for
%every trials based on the clusters it moves through (using the one
%clustering paradigm)
%
%INPUTS
%clusterIDs - nTrials x nEpochs array of cluster ids 
%leftTurns - nTrials x 1 array of left turn probabilities OR dataCell
%
%OPTIONAL INPUTS
%clusterThresh - minimum number of trials in a cluster to count. Default is
%   5.
%
%OUTPUTS
%deltaPLeft - nTrials x nTransitions matrix of change in p(left)
%startPleft - nTrials x nTransitions matrix of starting p(left)
%startNetEv - nTrials x nTransitions matrix of starting netEv
%
%ASM 6/15



%% handle inputs
clusterThresh = 5;
%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'clusterthresh'
                clusterThresh = varargin{argInd+1};
        end
    end
end

%% process 

%get leftTurns 
if iscell(leftTurns)
    dataCell = leftTurns;
    leftTurns = getCellVals(dataCell,'result.leftTurn');
    netEv = getNetEvidence(dataCell);
end

%get nTrials 
nTrials = size(clusterIDs,1);
nTransitions = size(clusterIDs,2)-1;

%initialize 
deltaPLeft = nan(nTrials,nTransitions);
startPLeft = nan(nTrials,nTransitions);
startNetEv = zeros(nTrials,nTransitions);

%loop through each trial and calculate 
for trialInd = 1:nTrials 
    
    %loop through each transition 
    for transition = 1:nTransitions 
        
        %get starting and ending cluster 
        startCluster = clusterIDs(trialInd,transition);
        endCluster = clusterIDs(trialInd,transition + 1);
        
        %get trials which match each 
        matchStartCluster = find(clusterIDs(:,transition) == startCluster);
        matchEndCluster = find(clusterIDs(:,transition + 1) == endCluster);
        
        %remove current trial 
        matchStartCluster(matchStartCluster == trialInd) = [];
        matchEndCluster(matchEndCluster == trialInd) = [];
        
        %ensure each is above cluster thresh 
        if length(matchStartCluster) < clusterThresh ||...
                length(matchEndCluster) < clusterThresh 
            continue;
        end
        
        %get p(left) for each 
        pLeftStart = mean(leftTurns(matchStartCluster));
        pLeftEnd = mean(leftTurns(matchEndCluster));
        if transition < size(netEv,2)
            startNetEv(trialInd,transition+1) = mean(netEv(matchStartCluster,transition+1));
        else
            startNetEv(trialInd,transition) = mean(netEv(matchStartCluster,size(netEv,2)));
        end
        
        %get difference 
        deltaPLeft(trialInd,transition) = pLeftEnd - pLeftStart;
        startPLeft(trialInd,transition) = pLeftStart;
        
    end
end