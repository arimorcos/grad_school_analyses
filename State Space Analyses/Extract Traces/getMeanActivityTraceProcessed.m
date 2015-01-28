function [meanTraces, stdTraces] = getMeanActivityTraceProcessed(dFFTraces,...
    dataCell,condition)
%getMeanActivityTraceProcessed.m Extracts mean activity trace for condition
%from processed data
%
%INPUTS
%dFFTraces - nNeurons x nBins x nTrials array of activity traces
%dataCell - dataCell containing imaging data
%condition - condition to filter based on. If empty, all.
%
%OUTPUTS
%meanTraces - nNeurons x nBins array of mean activity traces
%stdTraces - nNeurons x nBins array of std 
%
%ASM 1/14

if nargin < 2
    condition = [];
end

%find trials which match condition
matchInd = findTrials(dataCell,condition);

%filter dFFTraces
dFFTraces = dFFTraces(:,:,matchInd);

%take mean of each neuron
meanTraces = nanmean(dFFTraces,3);
stdTraces = nanstd(dFFTraces,0,3);


