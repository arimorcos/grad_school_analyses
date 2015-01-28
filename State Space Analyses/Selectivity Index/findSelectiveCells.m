function sigCells = findSelectiveCells(selectivity,selThresh,binThresh,bins,range)
%findSignificantCells.m Finds cells which are significant for nBins >=
%binThresh
%
%INPUTS
%sig - nNeurons x nBins array of selectivity index
%selThresh - min selectivity
%binThresh - minBins
%bins - bin IDs
%range - 1 x 2 array of min and max range
%
%OUTPUTS
%sigCells - nSigCells x 1 array
%
%ASM 1/14

if nargin < 5 || isempty(range)
    useRange = false;
else
    useRange = true;
end
if nargin < 4
    bins = [];
end

if useRange
    
    %subset by range
    binRange = bins >= range(1) &  bins < range(2);
    selectivity = selectivity(:,binRange);
end

%get nSelective bins
nSelBins = sum(abs(selectivity) >= selThresh,2);

%get sigCelss
sigCells = find(nSelBins >= binThresh);

