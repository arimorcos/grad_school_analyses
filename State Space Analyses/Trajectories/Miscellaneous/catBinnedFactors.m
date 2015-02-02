function [catFactor] = catBinnedFactors(dataCell,whichFactorSet)
%catBinnedTraces.m Concatenates binned traces into a nNeurons x nBins x
%nTrials array 
%
%INPUTS
%dataCell - dataCell containing imaging data
%varThresh - Between 0 and 1, amount of variance to account for. Will only
%   return the fewest number of PCs which account for this variance
%
%OUTPUTS
%catTraces - nNeurons x nBins x nTrials array
%catPCA - nPCs x nBins x nTrials array
%
%ASM 11/13


%check to ensure correct data contained
if ~isfield(dataCell{1},'imaging') || ~isfield(dataCell{1}.imaging,'binnedFactDFF')
    error('dataCell must contain binned imaging data');
end

%extract binned data into cell
allPlanesDFF = cellfun(@(x) x.imaging.binnedFactDFF{:}{whichFactorSet},dataCell,'UniformOutput',false);

%concatenate each trial
catFactor = cat(3,allPlanesDFF{:});


