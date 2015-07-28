function [shuffleTraces,leftTurns] = breakTrialAssociationForClassifier(imTrials)
%breakTrialAssociationForClassifier.m Subsets to 6-0 trials and breaks the
%trial-trial association for individual neurons (shuffles 6-0 left trials
%for each neuron independently)
%
%INPUTS`
%imTrials - dataCell containing imaging data
%
%OUTPUTS
%shuffTraces - nCells x nBins x nTrials array
%classLabels - nTrials x 1 array of class labels
%
%ASM 7/15

%ensure only 6-0 trials
assert(sum(findTrials(imTrials,'maze.numLeft==0,6'))==length(imTrials),...
    'Must only provide imaging 6-0 trials');

%get leftTurns
leftTurns = getCellVals(imTrials,'result.leftTurn');

% get traces
[~,traces] = catBinnedTraces(imTrials);

%get nNeurons
nNeurons = size(traces,1);

%initialize 
shuffleTraces = nan(size(traces));

for neuron = 1:nNeurons
    
    %shuffle left trials independently
    leftSub = traces(neuron,:,leftTurns);
    rightSub = traces(neuron,:,~leftTurns);
    
    %create new indices 
    leftShuffleInd = shuffleArray(1:sum(leftTurns));
    rightShuffleInd = shuffleArray(1:sum(~leftTurns));
    
    %shuffle 
    shuffleTraces(neuron,:,leftTurns) = leftSub(:,:,leftShuffleInd);
    shuffleTraces(neuron,:,~leftTurns) = rightSub(:,:,rightShuffleInd);
    
end