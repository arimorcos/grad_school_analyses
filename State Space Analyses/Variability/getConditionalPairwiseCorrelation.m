function out = getConditionalPairwiseCorrelation(dataCell)
%getConditionalPairwiseCorrelation.m Gets the pairwise correlation
%conditioned on the all trials, same turn, and 6-0 trials with same turn 
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%out - structure containing:
%   allCorr - nPairs x nBins correlations for all trial pairs
%   turnCorr - nPairs x nBins correlations for same turn trial pairs
%   turn60Corr - nPairs x nBins correlations for same turn 6-0 trial pairs
%
%ASM 10/15

% limit to correct trials 
dataCell = getTrials(dataCell, 'result.correct==1');

% get traces 
traces = catBinnedDeconvTraces(dataCell);
traces = traces(:,2:end-1,:);
out.yPosBins = dataCell{1}.imaging.yPosBins(2:end-1);

% get trial indices
leftTrials = findTrials(dataCell, 'result.leftTurn==1');
rightTrials = ~leftTrials;
left60Trials = findTrials(dataCell, 'result.leftTurn==1;maze.numLeft==6');
right60Trials = findTrials(dataCell, 'result.leftTurn==0;maze.numLeft==0');

%get all trials corr
out.allCorr = getPairwiseCorrelation(traces);

%get turn corr
leftCorr = getPairwiseCorrelation(traces(:,:,leftTrials));
rightCorr = getPairwiseCorrelation(traces(:,:,rightTrials));
out.turnCorr = cat(1, leftCorr, rightCorr);

%get different turn corr 
out.diffTurnCorr = getPairwiseInterCorrelation(traces(:,:,leftTrials),...
    traces(:,:,rightTrials));

%get 60 turn corr
left60Corr = getPairwiseCorrelation(traces(:,:,left60Trials));
right60Corr = getPairwiseCorrelation(traces(:,:,right60Trials));
out.turn60Corr = cat(1, left60Corr, right60Corr);