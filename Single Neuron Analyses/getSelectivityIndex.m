function selInd = getSelectivityIndex(dataCell,shuffle)
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
    shuffle= false;
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
[~,leftTraces] = catBinnedTraces(left60);
[~,rightTraces] = catBinnedTraces(right60);



%make positive 
convToPos = @(x) x + abs(min(x(:)));
if any(leftTraces(:) < 0)
    leftTraces = convToPos(leftTraces);
end
if any(rightTraces(:) < 0)
    rightTraces = convToPos(rightTraces);
end

%take mean across trials for each neuron 
meanLeftTraces = mean(leftTraces,3);
meanRightTraces = mean(rightTraces,3);

%get selectivity index
selInd = (meanLeftTraces - meanRightTraces)./(meanLeftTraces + meanRightTraces);