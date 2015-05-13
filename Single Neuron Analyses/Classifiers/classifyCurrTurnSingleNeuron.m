function acc = classifyCurrTurnSingleNeuron(dataCell)
%classifyCurrTurnSingleNeuron.m Classifies the current turn based on single
%neurons 
%
%INPUTS
%dataCell - dataCell containing imaging data 
%
%OUTPUTS
%acc - nNeurons x nBins array of accuracy for each neuron at each bin 
%
%ASM 5/15

%get left turn 
leftTurn = getCellVals(dataCell,'result.leftTurn');

%get binned traces 
[~,traces] = catBinnedTraces(dataCell);

%get sizes
[nNeurons,nBins,~] = size(traces);

%initialize 
acc = nan(nNeurons,nBins);

%loop through each neuron and classify 
for neuronInd = 1:nNeurons
   acc(neuronInd,:) = getClassifierAccuracyNew(traces(neuronInd,:,:),leftTurn);
   dispProgress('Calculating accuracy neuron %d/%d',neuronInd,neuronInd,nNeurons);
end