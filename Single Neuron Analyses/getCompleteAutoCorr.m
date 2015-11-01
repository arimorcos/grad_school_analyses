function [autoCorr, shuffleAutoCorr] = getCompleteAutoCorr(dataCell, useDeconv, window, shouldShuffle)
%getCompleteAutoCorr.m Gets the autocorrelation using a window of 1800
%frames (1 minute) for each cell
%
%INPUTS
%dataCell - imaging data
%useDeconv - booloena of whether to use deconvolved traces
%
%OUTPUTS
%autoCorr - nCells x window*2+1 array of autocorrelations
%
%ASM 10/15

if nargin < 4 || isempty(shouldShuffle)
    shouldShuffle = true;
end

if nargin < 3 || isempty(window)
    window = 1800;
end

if nargin < 2 || isempty(useDeconv)
    useDeconv = true;
end
nShuffles = 100;

%get traces
if useDeconv
    traces = dataCell{1}.imaging.filterDeconvTrace;
else
    traces = dataCell{1}.imaging.filterDFFTrace;
end

%get autocorrelation
nNeurons = size(traces,1);
autoCorr = nan(nNeurons, 2*window+1);
for neuron = 1:nNeurons
    autoCorr(neuron,:) = xcorr(traces(neuron,:), window, 'coeff');
end

%get shuffle
shuffleAutoCorr = nan(nNeurons, 2*window+1, nShuffles);
for shuffle = 1:nShuffles
    for neuron = 1:nNeurons
        shuffleAutoCorr(neuron,:,shuffle) = xcorr(shuffleArray(traces(neuron,:)),...
            window, 'coeff');
    end
    dispProgress('Shuffling %d/%d',shuffle,shuffle,nShuffles);
end