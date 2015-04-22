function switchProb = calculateSwitchProbability(clusterIDs,cMat,clusterTraj,dataCell)
%calculateSwitchProbability.m Creates clustered trajectories and then
%calculates the probability of a switch at each point 
%
%INPUTS
%clusterIDs - clusterIDs output by getClusteredMarkovMatrix
%cMat - cMat output by getClusteredMarkovMatrix
%clusterTraj - nTrials x 1 array of trajectory ids 
%
%OUTPUTS
%switchProb - nTraj x nPoints-1 array of switch probabilities at each
%   transition
%
%ASM 4/15

pointLabels = {'Maze Start','Segment 1','Segment 2','Segment 3','Segment 4',...
    'Segment 5','Segment 6','Early Delay','Late Delay','Turn'};

%get unique trajectories 
[uniqueTraj,nTrajTrials] = count_unique(clusterTraj);
nTraj = length(uniqueTraj);

%get nPoints
nPoints = size(clusterIDs,2);
nTransitions = nPoints - 1;

%get nTrials
nTrials = size(clusterIDs,1);

%initialize 
switchProb = nan(nTraj,nTransitions);

%loop through each transition 
for transition = 1:nTransitions
    isSwitch = nan(nTrials,1);
    for trialInd = 1:nTrials
        %get start and end cluster ID
        startCluster = clusterIDs(trialInd,transition);
        endCluster = clusterIDs(trialInd,transition+1);
        
        %get cluster turn probability
        startClusterTurnProb = cMat.leftTurn{transition}(startCluster == unique(clusterIDs(:,transition)));
        endClusterTurnProb = cMat.leftTurn{transition+1}(endCluster == unique(clusterIDs(:,transition+1)));
        
        %binarize
        startClusterTurnProb = startClusterTurnProb >= 0.5;
        endClusterTurnProb = endClusterTurnProb >= 0.5;
        
        %check if same turn probability
        isSwitch(trialInd) = startClusterTurnProb ~= endClusterTurnProb;
    end
    
    %loop through each trajectory 
    for trajInd = 1:nTraj
       %get matching indices 
       matchTrials = clusterTraj == uniqueTraj(trajInd);
       nMatch = sum(matchTrials);
       
       %get transition probability
       switchProb(trajInd,transition) = sum(isSwitch(matchTrials))/nMatch;
    end
end

%% plot 
figH = figure;
figH.Units = 'normalized';
figH.OuterPosition = [0 0 1 1];

axSwitch = axes('Position',[0.05 0.18 0.43 0.76]);

%sort trajectories 
totalSwitchProb = sum(switchProb,2);
[~,sortOrder] = sort(totalSwitchProb);
plotSwitchProb = switchProb(sortOrder,:);

imagescnan(1:nTransitions,1:nTraj,plotSwitchProb,[0 1]);

%label 
axSwitch.XTick = 1:nTransitions;
axSwitch.YTick = 1:nTraj;
axSwitch.XTickLabel = pointLabels(2:end);
axSwitch.XTickLabelRotation = -45;
axSwitch.FontSize = 20;
axSwitch.YLabel.String = 'Clustered trajectory index';

%add colorbar 
cBar = colorbar;
cBar.FontSize = 20;
cBar.Label.String = 'Switch probability';
cBar.Label.FontSize = 30;
cBar.Position(1) = 0.5;
drawnow;

%add nTrials axis 
axRightY = axes('Position',axSwitch.Position);
axRightY.YAxisLocation = 'right';
axRightY.YTick = 1:nTraj;
axRightY.YLim = [0.5 nTraj+0.5];
axRightY.YTickLabel = flipud(nTrajTrials(sortOrder));
axRightY.XTick = [];
uistack(axRightY,'bottom');
axRightY.FontSize = 15;

%add mean maze patterns
mazePatterns = getMazePatterns(dataCell);
meanMazePattern = nan(nTraj,size(mazePatterns,2));
for trajInd = 1:nTraj
    meanMazePattern(trajInd,:) = mean(mazePatterns(uniqueTraj(trajInd) == clusterTraj,:));
end
axMazePattern = axes('Position',[0.605 0.18 0.12 0.76]);
imagesc(1:size(mazePatterns,2),1:nTraj,meanMazePattern(sortOrder,:),[0 1]);
colormap(axMazePattern,redblue);
axMazePattern.YTickLabel = [];
axMazePattern.XTick = 1:size(mazePatterns,2);
axMazePattern.FontSize = 20;
axMazePattern.XTickLabel = pointLabels(2:7);
axMazePattern.XTickLabelRotation = -45;
axMazePattern.Title.String = 'Mean Maze Pattern';

%add behavioral features
behavFeatures = nan(nTraj,3);
leftTurns = getCellVals(dataCell,'result.leftTurn');
prevTurns = getCellVals(dataCell,'result.prevTurn');
correct = getCellVals(dataCell,'result.correct');
prevCorrect = getCellVals(dataCell,'result.prevCorrect');
for trajInd = 1:nTraj    
    behavFeatures(trajInd,1) = mean(leftTurns(uniqueTraj(trajInd) == clusterTraj));
    behavFeatures(trajInd,2) = mean(prevTurns(uniqueTraj(trajInd) == clusterTraj));
    behavFeatures(trajInd,3) = mean(correct(uniqueTraj(trajInd) == clusterTraj));
    behavFeatures(trajInd,4) = mean(prevCorrect(uniqueTraj(trajInd) == clusterTraj));
end
axBehavFeature = axes('Position',[0.76 0.18 0.15 0.76]);
imagesc(1:4,1:nTraj,behavFeatures(sortOrder,:),[0 1]);
colormap(axBehavFeature,redblue);
axBehavFeature.YTickLabel = [];
axBehavFeature.XTick = 1:size(mazePatterns,2);
axBehavFeature.FontSize = 20;
axBehavFeature.XTickLabel = {'Current turn','Previous Turn','Correct','Previous Correct'};
axBehavFeature.XTickLabelRotation = -45;
axBehavFeature.Title.String = 'Behavioral Features';

%add colorbar
cBar = colorbar('Position',[.92 0.18 0.02 0.76]);
cBar.FontSize = 20;
cBar.Label.String = 'Fraction left/correct';
cBar.Label.FontSize = 30;




