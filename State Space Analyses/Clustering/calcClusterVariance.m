function out = calcClusterVariance(imTrials)
%calcClusterVariance.m  Calculates the fraction of clusters visited by left
%6-0 and right 0-6 trials at each epoch
%
%INPUTS
%imTrials - imaging trials 
%
%OUTPUTS
%out - structure containing the following:
%   fracLeft - 1 x nEpochs array of fraction of clusters visited by left
%       6-0 trials
%   fracRight - same as fracLeft but for 0-6 right trials
%
%ASM 9/15

%cluster
[~,~,clusterIDs,~]=getClusteredMarkovMatrix(imTrials,'traceType','deconv');

%get nEpochs 
nEpochs = size(clusterIDs,2);

%get indices and for left and right correct trials 
correctLeft60Ind = findTrials(imTrials,'maze.numLeft==6;result.correct==1');
correctRight60Ind = findTrials(imTrials,'maze.numLeft==0;result.correct==1');

%get overall unique clusters 
nUnique = arrayfun(@(x) length(unique(clusterIDs(:,x))),1:nEpochs);

%get left and right unique clusters 
nUniqueLeft = arrayfun(@(x) length(unique(clusterIDs(correctLeft60Ind,x))),1:nEpochs);
nUniqueRight = arrayfun(@(x) length(unique(clusterIDs(correctRight60Ind,x))),1:nEpochs);

%get frac 
fracLeft = nUniqueLeft./nUnique;
fracRight = nUniqueRight./nUnique;

%store and output 
out.fracLeft = fracLeft;
out.fracRight = fracRight;
out.nUniqueLeft = nUniqueLeft;
out.nUniqueRight = nUniqueRight;
out.nUniqueAll = nUnique;