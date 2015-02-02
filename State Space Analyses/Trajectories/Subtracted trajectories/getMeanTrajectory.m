function [meanTraj, meanStart] = getMeanTrajectory(dataCell,varargin)
%getMeanTrajectory.m Calculates mean trajectory as a vector showing the
%change in position between each bin. Matches numbers of trials based on the
%eventual turn and difficulty 
%
%INPUTS
%dataCell - dataCell containing binned imaging data
%
%OPTIONAL INPUTS
%traceType - trace to use 
%whichFactorSet - factor set to use 
%
%OUTPUTS
%meanTraj - nNeurons/nFactors x nBins - 1 array of change in vector
%   position for every bin 
%meanStart - nNeurons/nFactors x 1 array of mean starting point
%
%ASM 1/15

%CONSTANT
FILTER_LESS_THAN = 0.4;

%assert that contains only binned imaging data
assert(all(getCellVals(dataCell,'imaging.imData')),'dataCell must contain only imaging data');
assert(isfield(dataCell{1}.imaging,'binnedDFFTraces'),'Imaging data must be binned');

%process varargin
whichFactorSet = 1;
traceType = 'dffFactor';
binRange = [-20 620];


if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'whichfactorset'
                whichFactorSet = varargin{argInd+1};
            case 'tracetype'
                traceType = varargin{argInd+1};
            case 'binrange'
                binRange = varargin{argInd+1};
        end
    end
end

%extract traces 
switch lower(traceType)
    case 'dfffactor'
        traces = catBinnedFactors(dataCell,whichFactorSet);
    case 'dff'
        [~,traces] = catBinnedTraces(dataCell);
    otherwise 
        error('Can''t process traceType: %s',traceType);
end

%filter based on binRange
binRangeInBinNum(1) = find(binRange(1) <= dataCell{1}.imaging.yPosBins,1,'first');
binRangeInBinNum(2) = find(binRange(2) >= dataCell{1}.imaging.yPosBins,1,'last');

%crop traces to binRange 
traces = traces(:,binRangeInBinNum(1):binRangeInBinNum(2),:);

%get diff 
diffTraces = diff(traces, 1, 2);

%get numLeft 
numLeft = getCellVals(dataCell,'maze.numLeft');
[uniqueNumLeft, nUniqueNumLeft] = count_unique(numLeft);
uniqueFrac = nUniqueNumLeft/max(nUniqueNumLeft);
uniqueNumLeft(uniqueFrac < FILTER_LESS_THAN) = []; %remove conditions less than the threshold 
nUniqueNumLeft(uniqueFrac < FILTER_LESS_THAN) = [];
nUnique = length(uniqueNumLeft);

%%%%%%%%trial match based on numLeft

%get minimum number of trials for a given difficulty 
minNumLeft = min(nUniqueNumLeft);

%loop through each unique condition and add to final 
matchedDiffTraces = nan(size(diffTraces,1),size(diffTraces,2),nUnique*minNumLeft);
matchedStartPoint = nan(size(diffTraces,1),nUnique*minNumLeft);
for numLeftInd = 1:nUnique
    
    %get temp traces matching numLeft
    numLeftTraces = diffTraces(:,:,numLeft==uniqueNumLeft(numLeftInd));
    numLeftStart = squeeze(traces(:,1,numLeft==uniqueNumLeft(numLeftInd)));
    
    %generate random subset
    keepInd = randsample(nUniqueNumLeft(numLeftInd),minNumLeft);
    
    %store 
    matchedDiffTraces(:,:,minNumLeft*(numLeftInd-1)+1:numLeftInd*minNumLeft) = ...
        numLeftTraces(:,:,keepInd);
    matchedStartPoint(:,minNumLeft*(numLeftInd-1)+1:numLeftInd*minNumLeft) = ...
        numLeftStart(:,keepInd);
end
    
%get mean diff
meanTraj = nanmean(matchedDiffTraces,3);

%get mean start point 
meanStart = nanmean(matchedStartPoint,2);
