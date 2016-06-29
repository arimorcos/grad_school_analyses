function [meanTraces, stdTraces, bins] = getMeanActivityTraceDCell(dataCell,...
    condition,binSize,trialIDs)
%getMeanActivityTraceDCell.m Extracts mean activity trace for condition
%from dataCell
%
%INPUTS
%dataCell - dataCell containing imaging data
%condition - condition to filter based on. If empty, all.
%binSize
%trialIDs - specific trialIDs to filteer based on. Overrides condition.
%   Must correspond to imSub
%
%OUTPUTS
%meanTraces - nNeurons x nBins array of mean activity traces
%stdTraces - nNeurons x nBins array of std 
%bins - bin labels
%
%ASM 1/14

if nargin < 4 
    trialIDs = [];
end
if nargin < 3 || isempty(binSize)
    binSize = 15;
end
if nargin < 2
    condition = [];
end

%get imSub
imSub = getTrials(dataCell,'imaging.imData == 1');

%bin if necessary
if ~isfield(imSub{1}.imaging,'binnedDFFTraces')
    imSub = binFramesByYPos(imSub,binSize);
end

%filter by condition
if isempty(condition)
    actSub = imSub;
else
    actSub = getTrials(imSub,condition);
end

%filter by trialIDs if non-empty
if ~isempty(trialIDs)
    actSub = imSub(trialIDs);
end

%get bins
bins = imSub{1}.imaging.yPosBins;

%get neuronal traces and threshold
% dFFTraces = thresholdTraces(dataCell{1}.imaging.completeDFFTrace,actSub,2);
[~,dFFTraces] = catBinnedTraces(actSub);
% dFFTraces = catBinnedDeconvTraces(actSub);

%take mean of each neuron
meanTraces = nanmean(dFFTraces,3);
stdTraces = nanstd(dFFTraces,0,3);


