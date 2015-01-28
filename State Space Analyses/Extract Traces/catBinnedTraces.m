function [catDGR, catDFF, catPCA, catTracesNonBinned] = catBinnedTraces(dataCell,varThresh)
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

if nargin < 2 || isempty(varThresh)
    varThresh = 1;
end

catDGR = [];
catPCA = [];
catTracesNonBinned = [];

%check to ensure correct data contained
if ~isfield(dataCell{1},'imaging') || ~isfield(dataCell{1}.imaging,'binnedDFFTraces')
    error('dataCell must contain binned imaging data');
end

%extract binned data into cell
allPlanesDFF = cellfun(@(x) x.imaging.binnedDFFTraces,dataCell,'UniformOutput',false);
% allPlanesDGR = cellfun(@(x) x.imaging.binnedDGRTraces,dataCell,'UniformOutput',false);
% allPlanesPCA = cellfun(@(x) x.imaging.binnedPCATraces,dataCell,'UniformOutput',false);
% allPlanesDFFNonBinned = cellfun(@(x) x.imaging.dFFTraces,dataCell,'UniformOutput',false);

%find out which planes are empty
filledPlanesDFF = cellfun(@(x) ~isempty(x),allPlanesDFF{1});
% filledPlanesPCA = cellfun(@(x) ~isempty(x),allPlanesPCA{1});
% filledPlanesDGR = cellfun(@(x) ~isempty(x),allPlanesDGR{1});
% filledPlanesDFFNonBinned = cellfun(@(x) ~isempty(x),allPlanesDFFNonBinned{1});

%subset allPlanes
dataPlanesDFF = cellfun(@(x) x(filledPlanesDFF),allPlanesDFF,'UniformOutput',false);
% dataPlanesPCA = cellfun(@(x) x(filledPlanesPCA),allPlanesPCA,'UniformOutput',false);
% dataPlanesDGR = cellfun(@(x) x(filledPlanesDGR),allPlanesDGR,'UniformOutput',false);
% dataPlanesDFFNonBinned = cellfun(@(x) x(filledPlanesPCA),allPlanesDFFNonBinned,'UniformOutput',false);

%find minimum number of frames
% minFrames = min(cellfun(@(x) size(x,2),dataPlanesDFFNonBinned{1}));
% 
% %crop frames
% for i = 1:length(dataPlanesDFFNonBinned)
%     dataPlanesDFFNonBinned{i} = cellfun(@(x) x(:,1:minFrames),dataPlanesDFFNonBinned{i},'UniformOutput',false);
% end

%concatenate each plane
dataPlanesCatDFF = cellfun(@(x) cat(1,x{:}),dataPlanesDFF,'UniformOutput',false);
% dataPlanesCatPCA = cellfun(@(x) cat(1,x{:}),dataPlanesPCA,'UniformOutput',false);
% dataPlanesCatDGR = cellfun(@(x) cat(1,x{:}),dataPlanesDGR,'UniformOutput',false);
% dataPlanesCatDFFNonBinned = cellfun(@(x) cat(1,x{:}),dataPlanesDFFNonBinned,'UniformOutput',false);

%concatenate each trial
catDFF = cat(3,dataPlanesCatDFF{:});
% catPCA = cat(3,dataPlanesCatPCA{:});
% catDGR = cat(3,dataPlanesCatDGR{:});
% catTracesNonBinned = cat(3,dataPlanesCatDFFNonBinned{:});

%find nPCs to keep
% nPCsKeep = find(dataCell{1}.imaging.dGRVarAccounted >= varThresh,1,'first');

%crop
% catPCA = catPCA(1:nPCsKeep,:,:);