function [PCA,trialIDs] = extractPCA(dataCell,varThresh)
%[PCA,trialIDs] = extractPCA(dataCell,varThresh) Extracts PCA data from
%dataCell and crops to only include PCs which account for varThresh
%
%INPUTS
%dataCell - dataCell containing postICA data
%varThresh - Between 0 and 1, amount of variance to account for. Will only
%   return the fewest number of PCs which account for this variance
%
%OUTPUTS
%PCA - nPCs x 
%trialIDs - 1 x nImagingTrials array containing ids of all trials extracted
%
%ASM 11/3

%ensure contains imaging data
if ~isfield(dataCell{1},'imaging') || sum(findTrials(dataCell,'imaging.imData == 1')) == 0
    error('dataCell must contain imaging data');
end

%get imaging subset
imSub = getTrials(dataCell,'imaging.imData == 1');
trialIDs = find(findTrials(dataCell,'imaging.imData == 1') == 1);

%bin if necessary
if ~isfield(imSub{1}.imaging,'binnedDFFTraces')
    imSub = binFramesByYPos(imSub,10);
end

%cat binned traces
[~, catPCA] = catBinnedTraces(imSub);

%find nPCs to keep
nPCsKeep = find(imSub{1}.imaging.varAccounted >= varThresh,1,'first');

%crop
PCA = catPCA(1:nPCsKeep,:,:);
