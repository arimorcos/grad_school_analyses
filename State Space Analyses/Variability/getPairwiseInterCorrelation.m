function corr = getPairwiseInterCorrelation(traces1, traces2)
%getPairwiseCorrelation.m Extracts the pairwise correlation coefficient at
%each bin in traces for all neurons 
%
%INPUTS
%traces - nNeurons x nBins x nTrials
%
%OUTPUTS
%corr - nPairs x nBins array of correlation for each bin for every pair of
%   trials
%
%ASM 10/15

%get nBins
nBins = size(traces1, 2);

%get nPairs
nPairs = size(traces1, 3) * size(traces2, 3);

%initialize corr
corr = nan(nPairs, nBins);

%loop through each bin 
for bin = 1:nBins 
    
    tempTraces1 = squeeze(traces1(:,bin,:));
    tempTraces1 = tempTraces1';
    
    tempTraces2 = squeeze(traces2(:,bin,:));
    tempTraces2 = tempTraces2';
    
    %get distance 
    tempCorr = 1 - pdist2(tempTraces1, tempTraces2, 'correlation');
    
    %store 
    corr(:,bin) = tempCorr(:);
end