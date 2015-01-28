function [dist] = calcSegActivityDistance(segTraces,distType)
%calcSegActivityDistance.m Calculates pairwise distance between every
%segment activity group and every other segment activity group
%
%INPUTS
%segTraces - nNeurons x nTrials*nSeg array of activity
%   following each segment onset
%
%OUTPUTS
%dist - nTrials*nSeg x nTrials*nSeg distance matrix 
%
%ASM 8/14

if nargin < 2 || isempty(distType)
    distType = 'euclidean';
end

%permute segTraces to nTrials x nNeurons (columns as variables, individual
%neurons, and rows as observations, trials)
segTraces = segTraces';

%calculate distance
dist = pdist(segTraces,distType);

%convert to squareform
dist = squareform(dist);