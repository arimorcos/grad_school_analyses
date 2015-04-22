function [meanDifference,shuffleDifference] = calcHighwayCorrect(clusterIDs,dataCell,refPoint)
%calcRelSwitchProb.m Calculates the relative probability of switching
%between the two provided reference points
%
%INPUTS
%clusterIDs - clusterIDs output by getClusteredMarkovMatrix
%dataCell - dataCell containing imaging data 
%refPoints - point to use as end point for highways 
%
%OUTPUTS
%
%ASM 4/15

nShuffles = 1000;
confInt = 95;

%cluster trajectories
clusterTraj = clusterClusteredTrajectories(clusterIDs,1:refPoint);

%get isCorrect
isCorrect = getCellVals(dataCell,'result.correct');

%get mean difference
meanDifference = calcMeanDiffFromNull(clusterTraj,isCorrect);

%calculate shuffle 
shuffleDifference = nan(nShuffles,1);
for shuffleInd = 1:nShuffles
    
%     tempIncorrect = zeros(size(trajCount));
%     for switchInd = 1:totalIncorrect
%         whichSwitch = randi(nTraj);  
%         while tempIncorrect(whichSwitch) >= trajCount(whichSwitch)
%             whichSwitch = randi(nTraj);
%         end
%         tempIncorrect(whichSwitch) = tempIncorrect(whichSwitch) + 1;
%     end
%     tempIncorrectProb = tempIncorrect./trajCount;
%     shuffleDifference(shuffleInd) = weights'*abs(tempIncorrectProb-nullProb);    
    shuffleTraj = shuffleArray(clusterTraj);
    shuffleDifference(shuffleInd) = calcMeanDiffFromNull(shuffleTraj,isCorrect);
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

end

function meanDiff = calcMeanDiffFromNull(clusterTraj,isCorrect)
%get unique trajectories
[uniqueTraj,trajCount] = count_unique(clusterTraj);
nTraj = length(uniqueTraj);

%get nTrials 
nTrials = sum(trajCount);

%get total incorrect
totalIncorrect = sum(~isCorrect);

%loop through each trajectory 
probIncorrect = nan(nTraj,1);
for trajInd = 1:nTraj
    %get match trials 
    matchTrials = find(uniqueTraj(trajInd) == clusterTraj);
    
    %calculate probability 
    probIncorrect(trajInd) = 1-sum(isCorrect(matchTrials))/length(matchTrials);
    
end

%calculate weighted mean difference from null probability 
nullProb = totalIncorrect/nTrials;
weights = trajCount/nTrials;
meanDiff = weights'*abs(probIncorrect-nullProb);
end
