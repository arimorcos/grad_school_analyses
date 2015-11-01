function out = shuffleTraces(in)
%shuffleTraces.m Shuffles the traces
%
%INPUTS
%in - nNeurons x nBins x nTrials traces 
%
%OUTPUTS
%out - nNeurons x nBins x nTrials shuffled traces 
%
%ASM 10/15

%get size 
[nNeurons, nBins, nTrials] = size(in);

%reshape 
out = reshape(in,nNeurons,[]);

%nPoints
% nBinTrials = nBins*nTrials;

%shufle 
for neuron = 1:nNeurons
%     shiftSize = randi(nBinTrials);
    out(neuron,:) = shuffleArray(out(neuron,:));
end

%reshape 
out = reshape(out,nNeurons,nBins,nTrials);