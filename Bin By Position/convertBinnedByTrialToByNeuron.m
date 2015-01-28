function [actByNeuron,imTrials] = convertBinnedByTrialToByNeuron(dataCell)
%convertBinnedByTrialToByNeuron.m Extracts neuronal activity from dataCell and
%converts population activity sorted by trial into a 1 x nNeurons cell
%containing nTrials x nBins arrays
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%actByNeuron - 1 x nPlanes cell containing 1 x nNeurons cell array with each
%   cell containing an array of nTrials x nBins arrays which can be easily
%    filtered to display an individual neurons activity on a specific subset 
%    of trials
%imTrials - indices of imaging trials (if all will be 1:nTrials)
%
%ASM 10/28/13

%get imaging subset
imSub = getTrials(dataCell,'imaging.imData == 1');
imTrials = findTrials(dataCell,'imaging.imData == 1');
imTrials = find(imTrials == 1);

%get number of planes
nPlanes = length(imSub{1}.imaging.binnedDFFTraces);

%initialize actByTrial
actByNeuron = cell(1,nPlanes);

%cycle through each plane
for i = 1:nPlanes
    
    %check if empty
    if isempty(imSub{1}.imaging.binnedDFFTraces{i})
        continue;
    end
    
    %get nNeurons
    nNeurons = size(imSub{1}.imaging.binnedDFFTraces{i},1);

    %initialize cell
    actByNeuron{i} = cell(1,nNeurons);

    %cycle through each trial and extract neurons
    for j = 1:length(imSub) %for each imaging trial

        %get neuronal data
        nData = imSub{j}.imaging.binnedDFFTraces{i};

        %deal into each neuron's array
        for k = 1:nNeurons
            actByNeuron{i}{k} = cat(1,actByNeuron{i}{k},nData(k,:));
        end
    end
    
end
