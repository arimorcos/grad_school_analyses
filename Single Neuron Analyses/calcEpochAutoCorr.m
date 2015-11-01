function autoCorr = calcEpochAutoCorr(tracePoints)
%calcEpochAutoCorr.m Calculates the auto correlation in terms of epochs 
%
%INPUTS
%tracePoints - nNeurons x nEpochs x nTrials array 
%
%OUTPUTS
%autoCorr - nNeurons x 2*nEpochs autocorrelation
%
%ASM 10/15

%get nNeurons 
nNeurons = size(tracePoints,1);

%reshape tracePoints
tracePoints = reshape(tracePoints, nNeurons, []);

%remove nans 
tracePoints = tracePoints(:,~any(isnan(tracePoints)));

%get autocorrelation for each
maxLag = 10;
autoCorr = nan(nNeurons,2*maxLag + 1);
for neuron = 1:nNeurons
    autoCorr(neuron,:) = xcorr(tracePoints(neuron,:),maxLag,'coeff');
end