function [meanDifference,shuffleDifference] = calcRelSwitchProb(clusterIDs,cMat,refPoints)
%calcRelSwitchProb.m Calculates the relative probability of switching
%between the two provided reference points
%
%INPUTS
%clusterIDs - clusterIDs output by getClusteredMarkovMatrix
%cMat - matrix containing turn probabilities 
%refPoints - 1 x 2 array of start and stop reference points 
%
%OUTPUTS
%
%ASM 4/15

nShuffles = 1000;
confInt = 95;

%cluster trajectories
clusterTraj = clusterClusteredTrajectories(clusterIDs,1:refPoints(1));

%get unique trajectories
[uniqueTraj,trajCount] = count_unique(clusterTraj);
nTraj = length(uniqueTraj);

%get nTrials 
nTrials = sum(trajCount);

%loop through each trajectory 
switchProb = nan(nTraj,1);
totalSwitches = 0;
for trajInd = 1:nTraj
    %get match trials 
    matchTrials = find(uniqueTraj(trajInd) == clusterTraj);
    
    isSwitch = false(length(matchTrials),1);
    %loop through each trial
    for trialInd = 1:length(matchTrials)
        %get start and end cluster ID
        startCluster = clusterIDs(matchTrials(trialInd),refPoints(1));
        endCluster = clusterIDs(matchTrials(trialInd),refPoints(2));
        
        %get cluster turn probability
        startClusterTurnProb = cMat.leftTurn{refPoints(1)}(startCluster ==...
            unique(clusterIDs(:,refPoints(1))));
        endClusterTurnProb = cMat.leftTurn{refPoints(2)}(endCluster ==...
            unique(clusterIDs(:,refPoints(2))));
        
        %binarize
        startClusterTurnProb = startClusterTurnProb >= 0.5;
        endClusterTurnProb = endClusterTurnProb >= 0.5;
        
        %check if same turn probability
        isSwitch(trialInd) = startClusterTurnProb ~= endClusterTurnProb;
        
    end
    
    %total switches 
    totalSwitches = totalSwitches + sum(isSwitch);
    
    %calculate probability 
    switchProb(trajInd) = sum(isSwitch)/length(isSwitch);
    
end

%calculate weighted mean difference from null probability 
nullProb = totalSwitches/nTrials;
weights = trajCount/nTrials;
meanDifference = weights'*abs(switchProb-nullProb);

%calculate shuffle 
shuffleDifference = nan(nShuffles,1);
for shuffleInd = 1:nShuffles
    
    tempSwitches = zeros(size(trajCount));
    for switchInd = 1:totalSwitches
        whichSwitch = randi(nTraj);  
        while tempSwitches(whichSwitch) >= trajCount(whichSwitch)
            whichSwitch = randi(nTraj);
        end
        tempSwitches(whichSwitch) = tempSwitches(whichSwitch) + 1;
    end
    tempSwitchProb = tempSwitches./trajCount;
    shuffleDifference(shuffleInd) = weights'*abs(tempSwitchProb-nullProb);    
end

%% plot 
figH = figure;
axH = axes;
hold(axH,'on');

%plot actual data 
scatH = scatter(1,meanDifference);
scatH.SizeData = 150;
scatH.MarkerFaceColor = 'flat';

%plot errorbar
lowInd = (100 - confInt)/2;
highInd = 100 - lowInd;
confVals = prctile(shuffleDifference,[lowInd highInd]);
medianShuffle = median(shuffleDifference);
confVals = abs(confVals - medianShuffle);
errH = errorbar(1,medianShuffle,confVals(1),confVals(2));
errH.LineWidth = 2;

%label 
axH.XTick = [];
axH.YLabel.String = 'Weighted mean difference from null';
axH.FontSize = 20;
axH.XLim = [0.9 1.1];
