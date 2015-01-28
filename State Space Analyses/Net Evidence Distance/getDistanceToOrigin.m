function [dist] = getDistanceToOrigin(segTraces)
%getDistanceToOrigin.m Function which computes distance to origin for each
%segment trace
%
%INPUTS
%segTraces - segment traces (mean values)
%
%OUTPUTS
%dist - nSegTraces x 1 array of distances to origin
%
%ASM 9/14

%get number of neurons
[nNeurons,nTrials] = size(segTraces);

%generate origin trace
origin = zeros(nNeurons,1);

%calculate distance
dist = arrayfun(@(x) calcEuclidianDist(origin,segTraces(:,x)),1:nTrials)';