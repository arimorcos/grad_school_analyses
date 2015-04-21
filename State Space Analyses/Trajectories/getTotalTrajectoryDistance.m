function trajDist = getTotalTrajectoryDistance(traces)
%getTotalTrajectoryDistance.m Calculates the total trajectory distance 
%
%INPUTS
%traces - nNeurons x nBins x nTrials array 
%
%OUTPUTS
%trajDist - nTrials x 1 array of total distances
%
%ASM 4/15

%get size
[~, nBins, nTrials] = size(traces);

%initialize 
trajDist = zeros(nTrials,1);

%loop through each trial 
for trialInd = 1:nTrials
    for binInd = 1:nBins-1
        %calculate distance and add
        trajDist(trialInd) = trajDist(trialInd) +...
            calcEuclideanDist(traces(:,binInd,trialInd),traces(:,binInd+1,trialInd));
    end
end