function out = calcPrevTrialClusterVariance(imTrials)
%calcPrevTrialClusterVariance.m  Calculates the fraction of clusters at the
%trial start visited by either previous left or previous right trials as
%well as the rewarded state 
%
%INPUTS
%imTrials - imaging trials 
%
%OUTPUTS
%out - structure containing the following:
%   fracPrevLeft - 1 x nEpochs fraction of clusters for previous left turns 
%   fracPrevRight - 1 x nEpochs fraction of clusters for previous right turns
%   fracPrevLeftCorrect - 1 x nEpochs fraction of clusters for previous correct left turns
%   fracPrevLeftError - 1 x nEpochs fraction of clusters for previous error left turns
%   fracPrevRightCorrect - 1 x nEpochs fraction of clusters for previous correct right turns
%   fracPrevRightError - 1 x nEpochs fraction of clusters for previous error right turns
%   
%ASM 9/15

%cluster
[~,~,clusterIDs,~]=getClusteredMarkovMatrix(imTrials,'traceType','deconv');

%get nEpochs 
nEpochs = size(clusterIDs,2);

%get indices and for left and right correct trials 
prevLeftInd = findTrials(imTrials,'result.prevTurn==1');
prevRightInd = findTrials(imTrials,'result.prevTurn==0');
prevLeftIndCorrect = findTrials(imTrials,'result.prevTurn==1;result.prevCorrect==1');
prevLeftIndError = findTrials(imTrials,'result.prevTurn==1;result.prevCorrect==0');
prevRightIndCorrect = findTrials(imTrials,'result.prevTurn==0;result.prevCorrect==1');
prevRightIndError = findTrials(imTrials,'result.prevTurn==0;result.prevCorrect==0');

%get overall unique clusters 
nUnique = arrayfun(@(x) length(unique(clusterIDs(:,x))),1:nEpochs);

%get left and right unique clusters 
nUniquePrevLeft = arrayfun(@(x) length(unique(clusterIDs(prevLeftInd,x))),1:nEpochs);
nUniquePrevRight = arrayfun(@(x) length(unique(clusterIDs(prevRightInd,x))),1:nEpochs);
nUniquePrevLeftCorrect = arrayfun(@(x) length(unique(clusterIDs(prevLeftIndCorrect,x))),1:nEpochs);
nUniquePrevLeftError = arrayfun(@(x) length(unique(clusterIDs(prevLeftIndError,x))),1:nEpochs);
nUniquePrevRightCorrect = arrayfun(@(x) length(unique(clusterIDs(prevRightIndCorrect,x))),1:nEpochs);
nUniquePrevRightError = arrayfun(@(x) length(unique(clusterIDs(prevRightIndError,x))),1:nEpochs);

%get frac 
fracPrevLeft = nUniquePrevLeft./nUnique;
fracPrevRight = nUniquePrevRight./nUnique;
fracPrevLeftCorrect = nUniquePrevLeftCorrect./nUnique;
fracPrevLeftError = nUniquePrevLeftError./nUnique;
fracPrevRightCorrect = nUniquePrevRightCorrect./nUnique;
fracPrevRightError = nUniquePrevRightError./nUnique;

%store and output 
out.fracPrevLeft = fracPrevLeft;
out.fracPrevRight = fracPrevRight;
out.fracPrevLeftCorrect = fracPrevLeftCorrect;
out.fracPrevLeftError = fracPrevLeftError;
out.fracPrevRightCorrect = fracPrevRightCorrect;
out.fracPrevRightError = fracPrevRightError;
out.nUniquePrevLeft = nUniquePrevLeft;
out.nUniquePrevRight = nUniquePrevRight;
out.nUniquePrevLeftCorrect = nUniquePrevLeftCorrect;
out.nUniquePrevLeftError = nUniquePrevLeftError;
out.nUniuqePrevRightCorrect = nUniquePrevRightCorrect;
out.nUniquePrevRightError = nUniquePrevRightError;
out.nUniqueAll = nUnique;