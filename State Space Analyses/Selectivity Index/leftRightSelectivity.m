function [selectivity,sig,confInt,bins] = leftRightSelectivity(dataCell,binSize,...
    nShuffles,confBound,conditions,shouldShuffle)
%leftRightSelectivity.m Calculates the left/right selectivity index
%(meanLeft - meanRight/(meanLeft + meanRight)) for each cell at each time
%bin, then performs a shuffle and determines pVal and significance
%
%INPUTS 
%dataCell - dataCell containing imaging data 
%binSize - binSize
%nShuffles - number of shuffles
%confBound - size of confidence intervals between 0 and 100
%
%OUTPUTS
%selectivity - nNeurons x nBins array of selectivity indices
%sig - nNeurons x nBins logical array of significance
%confInd - nNeurons x nBins x 2 array of lower and upper confidence
%   intervals
%bins - bins
%
%ASM 1/14
if nargin < 6 || isempty(shouldShuffle)
    shouldShuffle = false;
end
if nargin < 5 || isempty(conditions)
    conditions = {'maze.crutchTrial==0;result.correct==1;maze.numLeft==0,6;result.leftTurn==1'...
                  'maze.crutchTrial==0;result.correct==1;maze.numLeft==0,6;result.leftTurn==0'};
end
if nargin < 4 || isempty(confBound)
    confBound = 95;
end
if nargin < 3 || isempty(nShuffles)
    nShuffles = 1000;
end

%get imSub
imSub = getTrials(dataCell,'imaging.imData == 1');

%bin if necessary
if ~isfield(imSub{1}.imaging,'binnedDFFTraces')
    imSub = binFramesByYPos(imSub,binSize);
end

%get true selectivity
[selectivity, bins] = getSelectivityIndex(dataCell,binSize,conditions);

%initialize shuffle selectivity
shuffleSel = zeros(size(selectivity,1),size(selectivity,2),nShuffles);

%get nLeft and nTrials
nLeft = sum(findTrials(imSub,'maze.crutchTrial==0;result.correct==1;result.leftTurn==1'));
nTrials = length(imSub);

if shouldShuffle
    %waitbar
    hWait = waitbar(0,'Performing shuffle...');

    %perform shuffles
    for i = 1:nShuffles %for each shuffle

        %randomly generate left and right
        leftIDs = randsample(nTrials,nLeft);
        rightIDs = setdiff(1:nTrials,leftIDs);

        %get selectivity
        shuffleSel(:,:,i) = getSelectivityIndex(dataCell,binSize,conditions,leftIDs,rightIDs);

        waitbar(i/nShuffles,hWait,sprintf('Performing shuffle %d/%d...',i,nShuffles)); %update waitbar
    end

    %delete waitbar
    delete(hWait);

    %sort shuffle
    sortShuffle = sort(shuffleSel,3);

    %get lower and upper frac
    lowFrac = (100 - confBound)/200;
    upFrac = 1 - lowFrac;

    %get lower and upper ind
    lowInd = round(lowFrac*nShuffles);
    upInd = round(upFrac*nShuffles);

    %get lower and upper bounds
    confInt = sortShuffle(:,:,[lowInd upInd]);

    %determine significance
    sig = logical(selectivity >= confInt(:,:,2) | selectivity <= confInt(:,:,1));
else
    sig = [];
    confInt = [];
end


function [selectivity,bins] = getSelectivityIndex(dataCell,binSize,conditions,leftIDs,rightIDs)
%getSelectivityIndex.m Calculates the selectivity index 

if nargin < 5 
    rightIDs = [];
end
if nargin < 4 
    leftIDs = [];
end

if isempty(leftIDs) || isempty(rightIDs)
    %get mean left traces
    [leftTraces, ~, bins] = getMeanActivityTraceDCell(dataCell,...
        conditions{1},binSize);

    %get mean right traces
    [rightTraces, ~, ~] = getMeanActivityTraceDCell(dataCell,...
        conditions{2},binSize);
else
    %get mean left traces
    [leftTraces, ~, bins] = getMeanActivityTraceDCell(dataCell,...
        [],binSize,leftIDs);

    %get mean right traces
    [rightTraces, ~, ~] = getMeanActivityTraceDCell(dataCell,...
        [],binSize,rightIDs);
end

%calculate selectivity index for each neuron
selectivity = (leftTraces - rightTraces)./(leftTraces + rightTraces);