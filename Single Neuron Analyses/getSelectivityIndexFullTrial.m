function selInd = getSelectivityIndexFullTrial(dataCell,shuffle)
%getSelectivityIndex.m Returns a nNeurons x nBins selectivity index based
%on left and right 6-0 trials 
%
%INPUTS
%dataCell - dataCell containing binned imaging data 
%
%OUTPUTS
%selInd - nNeurons x nBins selectivity index. 1 means left preference, -1
%   right preference
%
%ASM 7/15

if nargin < 2 || isempty(shuffle)
    shuffle = false;
end

%get left and right 60
left60 = getTrials(dataCell,'result.correct==1;maze.numLeft==6');
right60 = getTrials(dataCell,'result.correct==1;maze.numLeft==0');

%shuffle if necessary 
if shuffle
    allTrials = cat(2,left60,right60);
    leftInd = randsample(length(allTrials),length(left60));
    rightInd = setdiff(1:length(allTrials),leftInd);
    left60 = allTrials(leftInd);
    right60 = allTrials(rightInd);
end

%get binned traces 
leftTraces = catBinnedDeconvTraces(left60);
rightTraces = catBinnedDeconvTraces(right60);

%make positive 
% convToPos = @(x) x + abs(min(x(:)));
convToPos = @(x) bsxfun(@plus,x,abs(min(min(x,[],3),[],2)));
if any(leftTraces(:) < 0)
    leftTraces = convToPos(leftTraces);
end
if any(rightTraces(:) < 0)
    rightTraces = convToPos(rightTraces);
end

%normalize 
% maxVals = max(max(cat(3,leftTraces,rightTraces),[],3),[],2);
% leftTraces = bsxfun(@rdivide, leftTraces, maxVals);
% rightTraces = bsxfun(@rdivide, rightTraces, maxVals);

%take mean across bins and then trials for each neuron 
meanLeftTraces = nanmean(nanmean(leftTraces, 2), 3);
meanRightTraces = nanmean(nanmean(rightTraces, 2) ,3);

%get selectivity index
selInd = (meanLeftTraces - meanRightTraces)./(meanLeftTraces + meanRightTraces);