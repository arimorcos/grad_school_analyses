function selInd = getSelectivityIndex(dataCell)
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

%get left and right 60
left60 = getTrials(dataCell,'result.correct==1;maze.numLeft==6');
right60 = getTrials(dataCell,'result.correct==1;maze.numLeft==0');

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