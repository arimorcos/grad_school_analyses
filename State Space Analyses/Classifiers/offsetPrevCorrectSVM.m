function [accuracy, shuffleAccuracy] = offsetPrevCorrectSVM(dataCell, offset)
%offsetPrevCorrectSVM.m Offsets error and correct trials by moving correct
%trials forward 2 seconds and performs SVM analysis for previous correct
%trial
%
%INPUTS
%dataCell - dataCell containing imaging data 
%offset - offset in seconds 
%
%ASM 7/15

% get binned dataframes and traces 
[~,traces] = catBinnedTraces(dataCell);
dataFrames = catBinnedDataFrames(dataCell);

%remove first and last bins 
traces = traces(:,2:end-1,:);
dataFrames = dataFrames(:,2:end-1,:);

%get size 
[~,nBins,nTrials] = size(traces);

%extract time frames 
timeFrames = squeeze(dataFrames(1,:,:));

%get prevError trials 
prevCorrect = logical(getCellVals(dataCell, 'result.prevCorrect'));

%get first time for each correct trial 
firstTimes = timeFrames(1,:);

%get datenum for 2 seconds 
dnumTwoSec = datenum([0,0,0,0,0,offset]);
% dnumTwoSec = datenum([0,0,0,0,0,0]);

%add 2 seconds to each first correct time 
offsetTimes = firstTimes + dnumTwoSec;

%generate new array 
offsetTraces = nan(size(traces));

%find first index for each 
for ind = 1:nTrials
    
    if prevCorrect(ind) %if previous trial correct
        %get offset ind
        offsetInd = find(offsetTimes(ind) > timeFrames(:,ind),1,'last');
        if isempty(offsetInd); offsetInd = 1; end
        
        %store offset 
        offsetTraces(:,1:nBins - offsetInd + 1,ind) = traces(:,offsetInd:end,ind);
    else
        %copy traces to whole
        offsetTraces(:,:,ind) = traces(:,:,ind);

    end
end

%crop out any bins with nans 
binHasNans = any(any(isnan(offsetTraces),3));
offsetTraces = offsetTraces(:,~binHasNans,:);

%run svm 
% acc = getSVMAccuracy(offsetTraces, prevCorrect, 'cParam',4.2, 'gamma', 0.04);
[accuracy,shuffleAccuracy] = classifyAndShuffle(offsetTraces, prevCorrect,...
    {'accuracy','shuffleAccuracy'}, 'nshuffles', 100, 'c',4.2, 'gamma', 0.04);
