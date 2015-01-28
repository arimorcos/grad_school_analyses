function [actByTrial,imSub,imTrials] = convertPopTrialToIndTrial(dataCell)
%convertPopTrialToIndTrial.m Extracts neuronal activity from dataCell and
%converts population activity sorted by trial into a 1 x nNeurons cell
%containing nTrials cells of row vectors
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%actByTrial - 1 x nNeurons cell array with each cell containing an array of
%   nTrials cells of row vectors which can be easily filtered to display an
%   individual neurons activity on a specific subset of trials
%imSub - subset of dataCell with imaging data
%imTrials - indices of imaging trials (if all will be 1:nTrials)
%
%ASM 10/28/13

%get imaging subset
imSub = getTrials(dataCell,'imaging.imData == 1');
imTrials = findTrials(dataCell,'imaging.imData == 1');
imTrials = find(imTrials == 1);

%get nNeurons
nNeurons = size(imSub{1}.imaging.dFFTraces,1);

%initialize cell
actByTrial = cell(1,nNeurons);
for i = 1:nNeurons
    actByTrial{i} = cell(1,length(imSub));
end

%cycle through each trial and extract neurons
for i = 1:length(imSub) %for each imaging trial
    
    %get neuronal data
    nData = imSub{i}.imaging.dFFTraces;
    
    %deal into each neurons array
    for j = 1:nNeurons
        actByTrial{j}{i} = nData(i,:);
    end
end
