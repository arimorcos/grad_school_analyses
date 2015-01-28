function [PCA,variance] = getNeuronPCA(dFF)
%getNeuronPCA.m Function to get the PCAs for dFF matrix
%
%INPUTS
%dFF - nNeurons x nFrames dF/F traces
%
%OUTPUTS
%PCA - nPCs x nFrames principal components
%variance - 1 x nPCs array of variance accounted for
%
%ASM 11/13

%normalize - divide by sqrt(std)
dFFSTD = sqrt(std(dFF,0,2));
normDFF = dFF./repmat(dFFSTD,1,size(dFF,2));

%perform PCA
[~,score,latent] = princomp(normDFF');

%get PCAs
PCA = score';

%get variance accounted for
variance = cumsum(latent)./sum(latent);