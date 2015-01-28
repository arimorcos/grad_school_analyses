function [seqTraces,bins,unSortTrace,sortInd] = makeSeqSubset(dataCell,condition,sortOrder,gCells)
%makeSeqSubset.m Creates sequence by sorting data by time of peak activity 
%
%INPUTS
%dataCell - dataCell containing imaging data
%condition - condition to filter based on. If empty, all.
%sortOrder - designate a sortOrder
%gCells = cells to use
%
%OUTPUTS
%seqTraces - nNeurons x nBins array sorted by time of peak activity
%bins - bin labels
%unSortTrace - unsorted trace
%sortInd - sortOrder used
%
%ASM 1/14

if nargin < 3 || isempty(sortOrder)
    preSorted = false;
else
    preSorted = true;
end

%get mean activity
[meanTraces,~,bins] = getMeanActivityTraceDCell(dataCell,condition);

if nargin < 4 || isempty(gCells)
    gCells = 1:size(meanTraces,1);
end

meanTraces = meanTraces(gCells,:);

%store unsortTrace
unSortTrace = meanTraces;

if preSorted
    sortInd = sortOrder;
else
    %find time of peak activity
    [~,maxBin] = max(meanTraces,[],2);

    %sort times
    [~,sortInd] = sort(maxBin);
end

%sort meanTraces
seqTraces = meanTraces(sortInd,:);