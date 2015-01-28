% function figH = plotActivityVsNetEv(dataCell,neuronID)
%plotActivityVsNetEv.m Function to plot activity of a given neuron vs net
%evidence
%
%INPUTS
%dataCell - dataCell containing imaging and integration data
%neuronID - neuron to plot against net evidence
%segRanges - nSeg x 2 array of segment starts and ends
%
%OUTPUTS
%figH - figure handle
%
%ASM 7/14

% if nargin < 3 || isempty(segRanges)
    segRanges(:,1) = 1:10:51;
    segRanges(:,2) = 10:10:60;
% end

%get net evidence
netEv = getNetEvidence(dataCell);

%get number of unique evidence values
uniqueNetEv = unique(netEv(:));
nUniqueEv = length(uniqueNetEv);

%extract binned traces
catTraces = catBinnedTraces(dataCell);

%isolate neuron of interest
neuronTraces = squeeze(catTraces(neuronID,:,:));

%loop through each net evidence condition and extract segments matching 


