function [means,stds] = difficultyMeanDistTrialControlled(in)
%difficultyMeanDistTrialControlled.m Gets means of a random subpopulation
%of each difficulty controlled to the smallest number of trials
%
%INPUTS
%in - structure outputted by compareSegDistances
%
%OUTPUTS
%means - nSeg x nDiff array of means
%std - nSeg x nDiff array of standard deviations
%
%ASM 9/14

%get minimum number of trials
diffLengths = cellfun(@length,in.diffDistances);
minDiffLength = min(diffLengths(:));

%get number of conditions
nCond = numel(diffLengths);

%initialize 
means = zeros(size(diffLengths));
stds = zeros(size(diffLengths));

%loop through each and generate indices
for i = 1:nCond
    
    %generate indices
    indices = randsample(diffLengths(i),minDiffLength);
    
    %get subset 
    subset = in.diffDistances{i}(indices);
    
    %take mean and std
    means(i) = nanmean(subset);
    stds(i) = nanstd(subset);
end
    
    
