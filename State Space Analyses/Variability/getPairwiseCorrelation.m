function corr = getPairwiseCorrelation(traces)
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
[~, nBins, nTrials] = size(traces);

%get nPairs
nPairs = nchoosek(nTrials, 2);

%initialize corr
corr = nan(nPairs, nBins);

%loop through each bin 
for bin = 1:nBins 
    
    tempTraces = squeeze(traces(:,bin,:));
    tempTraces = tempTraces';
    
    %get distance 
    tempCorr = 1 - pdist(tempTraces, 'correlation');
    
    %store 
    corr(:,bin) = tempCorr;
end