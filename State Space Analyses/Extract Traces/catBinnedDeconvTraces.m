function [catTraces] = catBinnedDeconvTraces(dataCell)
%catBinnedDeconvTraces.m Concatenates binned traces into a nNeurons x nBins x
%nTrials array 
%
%INPUTS
%dataCell - dataCell containing imaging data
%varThresh - Between 0 and 1, amount of variance to account for. Will only
%   return the fewest number of PCs which account for this variance
%
%OUTPUTS
%catTraces - nNeurons x nBins x nTrials array
%
%ASM 7/15


%check to ensure correct data contained
if ~isfield(dataCell{1},'imaging') || ~isfield(dataCell{1}.imaging,'binnedDeconvTraces')
    error('dataCell must contain binned imaging data');
end

%extract binned data into cell
allPlanesDeconv = cellfun(@(x) x.imaging.binnedDeconvTraces,dataCell,'UniformOutput',false);

%find out which planes are empty
filledPlanesDeconv = cellfun(@(x) ~isempty(x),allPlanesDeconv{1});

%subset allPlanes
dataPlanesDeconv = cellfun(@(x) x(filledPlanesDeconv),allPlanesDeconv,'UniformOutput',false);

%concatenate each plane
dataPlanesCatDeconv = cellfun(@(x) cat(1,x{:}),dataPlanesDeconv,'UniformOutput',false);

%concatenate each trial
catTraces = cat(3,dataPlanesCatDeconv{:});
