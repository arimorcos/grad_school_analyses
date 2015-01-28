function meanSubTraj = getMeanSubtractedTrajectories(dataCell)
%getMeanSubtractedTrajectories.m Extracts mean subtracted trajectories from
%dataCell
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%meanSubTraj - nFactors/nNeurons x nBins x nTrials array of mean subtracted
%   trajectories
%
%ASM 1/15

%get base trajectories 
[binVec, startVec] = getBinnedVectors(dataCell);

%permute startVec to nFactors/nNeurons x 1 x nTrials
startVec = permute(startVec,[1 3 2]);

%get mean trajectories
meanTraj = getMeanTrajectory(dataCell);

%subtract meanTraj from binVec
meanSubDiff = bsxfun(@minus, binVec, meanTraj);

%recreate trajectories from diff 
meanSubTraj = cumsum(cat(2,startVec,meanSubDiff),2);