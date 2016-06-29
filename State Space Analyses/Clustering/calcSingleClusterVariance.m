function out = calcSingleClusterVariance(imTrials, shuffle, nShuffles)
%calcSingleClusterVariance.m  Calculates the fraction of clusters visited
%by trials originating from a single cluster separately on left and right
%6-0 trials
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

if nargin < 3 || isempty(nShuffles)
    nShuffles = 1000;
end

if nargin < 2 || isempty(shuffle)
    shuffle = false;
end

perc = 10;

%get indices and for left and right correct trials
correctLeft60 = getTrials(imTrials,'maze.numLeft==6;result.correct==1');
correctRight60 = getTrials(imTrials,'maze.numLeft==0;result.correct==1');

%cluster
[~,~,leftClusterIDs,~]=getClusteredMarkovMatrix(correctLeft60,'traceType','deconv',...
    'perc', perc);
[~,~,rightClusterIDs,~]=getClusteredMarkovMatrix(correctRight60,'traceType','deconv',...
    'perc', perc);

%get nEpochs
nEpochs = size(leftClusterIDs,2);

%get overall unique clusters
nUniqueLeft = arrayfun(@(x) length(unique(leftClusterIDs(:,x))),1:nEpochs);
nUniqueRight = arrayfun(@(x) length(unique(rightClusterIDs(:,x))),1:nEpochs);

%get start clusters
leftStartClusters = unique(leftClusterIDs(:, 1));
rightStartClusters = unique(rightClusterIDs(:, 1));

[leftFrac, rightFrac] = getFracs(leftClusterIDs, rightClusterIDs, ...
    leftStartClusters, rightStartClusters, nEpochs, nUniqueLeft, nUniqueRight);

if shuffle
    shuffleLeftFrac = nan(size(leftFrac, 1), nEpochs, nShuffles);
    shuffleRightFrac = nan(size(rightFrac, 1), nEpochs, nShuffles);
    parfor shuffle_ind = 1:nShuffles
        shuffle_leftClusterIDs = shuffleClusterIDs(leftClusterIDs);
        shuffle_rightClusterIDs = shuffleClusterIDs(rightClusterIDs);
        
        [shuffleLeftFrac(:, :, shuffle_ind), shuffleRightFrac(:, :, shuffle_ind)] =...
            getFracs(shuffle_leftClusterIDs, shuffle_rightClusterIDs, ...
            leftStartClusters, rightStartClusters, nEpochs, nUniqueLeft, nUniqueRight);
    end
else
    shuffleLeftFrac = [];
    shuffleRightFrac = [];
end

% calc means 
allFrac = cat(1, rightFrac, leftFrac);
allShuffleFrac = cat(1, shuffleRightFrac, shuffleLeftFrac);
meanFrac = mean(allFrac);
shuffleMeanFrac = squeeze(mean(allShuffleFrac, 1))';

%store and output
out.leftFrac = leftFrac;
out.rightFrac = rightFrac;
out.allFrac = allFrac;
out.meanFrac = meanFrac;
out.nUniqueLeft = nUniqueLeft;
out.nUniqueRight = nUniqueRight;
out.shuffleLeftFrac = shuffleLeftFrac;
out.shuffleRightFrac = shuffleRightFrac;
out.allShuffleFrac = allShuffleFrac;
out.shuffleMeanFrac = shuffleMeanFrac;

end

function [leftFrac, rightFrac] = getFracs(leftClusterIDs, rightClusterIDs, ...
    leftStartClusters, rightStartClusters, nEpochs, nUniqueLeft, nUniqueRight)

thresh = 1;

% loop through each start cluster
leftFrac = nan(length(leftStartClusters), nEpochs);
for leftStart = 1:length(leftStartClusters)
    
    % subset trials
    keep_ind = leftClusterIDs(:, 1) == leftStartClusters(leftStart);
    sub = leftClusterIDs(keep_ind, :);
    
    % get nUnique
    nUniqueSub = nan(1, nEpochs);
    for epoch = 1:nEpochs 
        [~, count] = count_unique(sub(:, epoch));
        nUniqueSub(epoch) = sum(count >= thresh);
    end
    
    leftFrac(leftStart, :) = nUniqueSub./nUniqueLeft;
end

% loop through each start cluster
rightFrac = nan(length(rightStartClusters), nEpochs);
for rightStart = 1:length(rightStartClusters)
    
    % subset trials
    keep_ind = rightClusterIDs(:, 1) == rightStartClusters(rightStart);
    sub = rightClusterIDs(keep_ind, :);
    
    % get nUnique
    nUniqueSub = nan(1, nEpochs);
    for epoch = 1:nEpochs 
        [~, count] = count_unique(sub(:, epoch));
        nUniqueSub(epoch) = sum(count >= thresh);
    end
    
    rightFrac(rightStart, :) = nUniqueSub./nUniqueRight;
end

end