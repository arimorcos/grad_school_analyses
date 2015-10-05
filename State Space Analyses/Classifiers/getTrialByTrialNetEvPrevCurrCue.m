function out = getTrialByTrialNetEvPrevCurrCue(dataCell)
%getTrialByTrialNetEvPrevCurrCue.m Calculates the trial by trial (and
%segment by segment) information for each cue's net evidence error,
%previous cue accuracy, and current cue accuracy 
%
%INPUTS
%dataCell - dataCell containing imaging data 
%
%OUTPUTS
%out - structure containing: 
%
%
%
%ASM 10/15

%cluster
[~,~,clusterIDs,~] = getClusteredMarkovMatrix(dataCell);

% get previous cue info 
[~,~,~,trialInfo] = predictHistoryFromClusters(clusterIDs,dataCell,1);
prevCueCorrect = trialInfo.guess == trialInfo.real;

%get training indices 
nTrials = length(dataCell);
nSegTrials = 6*nTrials;
trainInd = 1:nSegTrials;
for seg = 1:6
    matchSegTrials = (seg-1)*nTrials + ...
        trialInfo.whichTrials(trialInfo.whichSeg == seg);
    trainInd(matchSegTrials) = NaN;
end
trainInd = trainInd(~isnan(trainInd));

%  get net evidence info 
classOut = classifyNetEvGroupSegSVM(dataCell,'trainInd',trainInd,...
    'conditions',{''});
netEvResidual = abs(classOut.testClass - classOut.guess);

out.prevCueCorrect = prevCueCorrect;
out.netEvResidual = netEvResidual;

% fprintf('Mean residual for prevCueCorrect: %.3f \n', mean(netEvResidual(prevCueCorrect)));
% fprintf('Mean residual for prevCueError: %.3f \n', mean(netEvResidual(~prevCueCorrect)));