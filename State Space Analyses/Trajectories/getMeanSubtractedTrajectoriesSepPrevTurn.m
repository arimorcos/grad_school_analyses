function meanSubTraj = getMeanSubtractedTrajectoriesSepPrevTurn(dataCell)
%getMeanSubtractedTrajectoriesSepPrevTurn.m Extracts mean subtracted
%trajectories using separate mean trajectories for trials with different
%previous turns
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%meanSubTraj - nFactors/nNeurons x nBins x nTrials array of mean subtracted
%   trajectories
%
%ASM 1/15

%separate by prevTurn
prevLeftInd = findTrials(dataCell,'prevTrial;result.leftTurn==1');
prevLeft = dataCell(prevLeftInd);

prevRightInd = findTrials(dataCell,'prevTrial;result.leftTurn==0');
prevRight = dataCell(prevRightInd);

%calculate mean trajectories for each 
meanLeftTraj = getMeanSubtractedTrajectories(prevLeft);
meanRightTraj = getMeanSubtractedTrajectories(prevRight);

%initialize new array 
meanSubTraj = nan(size(meanLeftTraj,1),size(meanLeftTraj,2),...
    length(dataCell));

%copy into complete array
meanSubTraj(:,:,prevLeftInd) = meanLeftTraj;
meanSubTraj(:,:,prevRightInd) = meanRightTraj;

%crop to only those containing previous trial
hasPrevTrial = findTrials(dataCell,'prevTrial;result.correct==0,1');
meanSubTraj = meanSubTraj(:,:,hasPrevTrial);