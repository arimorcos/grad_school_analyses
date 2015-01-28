function [accuracy,confidenceIntervals,shuffleAccuracy] = leastDistClassifier(...
    dataCell,condition,shouldPlot,shouldShuffle,shouldThresh,usePCs,varThresh,...
    nShuffles,confInt,nSTD,binSize,gNeurons)
%six0Classifier.m Basic leave one out classifier based on euclidean
%distance for 6-0 trials
%
%INPUTS
%dataCell - dataCell containing imaging data
%condition - condition on which to filter. can be cell of multiple
%   conditions
%shouldPlot - should plot. Default is false
%shouldShuffle - should shuffle? default is false
%shouldThresh - should threshold traces. Default is false
%usePCs - should use PCs. Default is false
%varThresh - if using PCs, how much variance? Between 0 and 1. Default is
%       0.8
%nShuffles - number of shuffles. Default is 500.
%confInt - Number between 0 and 1 for confidence interval. Default is 0.95
%nSTD - number of standard deviations for threshold. Default is 3.
%binSize - binSize
%gNeurons - neurons to use
%
%OUTPUTS
%accuracy - 1 x nBins array of accuracy
%confidenceIntervals - 2 x nBins array of lower and upper confidence bounds
%shuffleAccuracy - nShuffles x nBins array of shuffle results
%
%ASM 11/13

segRanges = [0:80:480];

if nargin < 12
    gNeurons = [];
end
if nargin < 11 || isempty(binSize)
    binSize = 5;
end
if nargin < 10 || isempty(nSTD)
    nSTD = 3;
end
if nargin < 9 || isempty(confInt)
    confInt = 0.95;
end
if nargin < 8 || isempty(nShuffles)
    nShuffles = 500;
end
if nargin < 7 || isempty(varThresh)
    varThresh = 0.8;
end
if nargin < 6 || isempty(usePCs)
    usePCs = false;
end
if nargin < 5 || isempty(shouldThresh)
    shouldThresh = false;
end
if nargin < 4 || isempty(shouldShuffle)
    shouldShuffle = false;
end
if nargin < 3 || isempty(shouldPlot)
    shouldPlot = false;
end

%only take 6-0 correct imaging non-crutch trials
% imSub = getTrials(dataCell,'imaging.imData==1;maze.crutchTrial==0;maze.numLeft==0,6;result.correct==1');
imSub = getTrials(dataCell,'imaging.imData==1');
if ~isempty(condition)
    if ~iscell(condition)
        condition = {condition};
    end
    for i = 1:length(condition)
        imSub = getTrials(imSub,condition{i});
    end
end

if isempty(imSub)
    error('No trials match condition');
end

%bin if necessary
if ~isfield(imSub{1}.imaging,'binnedDGRTraces')
    imSub = binFramesByYPos(imSub,binSize);
end

%get number of bins
nBins = length(imSub{1}.imaging.yPosBins);

%get neuronal traces
[dGRTraces,dFFTraces,PCATraces] = catBinnedTraces(imSub,varThresh);

%threshold
% reshapeDFF = reshape(dFFTraces,size(dFFTraces,1),size(dFFTraces,2)*size(dFFTraces,3));
% maxDFF = max(reshapeDFF,2);
% threshold = 0.4*maxDFF;
% for i = 1:size(dFFTraces,1)
%     reshapeDFF(i,reshapeDFF(i,:) < threshold(i)) = 0;
% end
% dFFTraces = reshape(reshapeDFF,size(dFFTraces));

%threshold traces
if shouldThresh
    dGRTraces = thresholdTraces(dataCell{1}.imaging.completeDGRTrace,imSub,nSTD);
end

%keep only good neurons
if ~isempty(gNeurons)
    dGRTraces = dGRTraces(gNeurons,:,:);
end

%get nTrials
nTrials = length(imSub);

%get actual accuracy

%get left turns
leftTurns = find(getCellVals(imSub,'result.leftTurn')==1);
rightTurns = find(getCellVals(imSub,'result.leftTurn')==0);
nLeft = length(leftTurns);

accuracy = getClassifierAccuracy(nTrials,nBins,dFFTraces,PCATraces,...
    leftTurns,rightTurns,usePCs);

%perform shuffle
if shouldShuffle
    shuffleAccuracy = zeros(nShuffles,nBins); %initialize array
    hWait = waitbar(0,'Performing shuffle...');
    for i = 1:nShuffles %for each shuffle
        
        %generate random trialIDs
        leftTurnsShuffle = sort(randsample(nTrials,nLeft)');
        rightTurnsShuffle = setdiff(1:nTrials,leftTurnsShuffle);
        
        shuffleAccuracy(i,:) = getClassifierAccuracy(nTrials,nBins,dGRTraces,PCATraces,...
            leftTurnsShuffle,rightTurnsShuffle,usePCs);
        
        waitbar(i/nShuffles,hWait,sprintf('Performing shuffle %d/%d...',i,nShuffles)); %update waitbar
    end
    
    %sort shuffle accuracy
    shuffleAccuracy = sort(shuffleAccuracy,1);
    
    %delete waitbar
    delete(hWait);
    
    %find confInt values
    lowConf = (1 - confInt)/2;
    highConf = 1 - lowConf;
    lowInd = round(lowConf*nShuffles);
    highInd = round(highConf*nShuffles);
    
    %get confidence intervals
    confidenceIntervals = shuffleAccuracy([highInd lowInd],:);
    confidenceIntervals = abs(confidenceIntervals - .5);
else
    confidenceIntervals = [];
    shuffleAccuracy = [];
end
%%%%%%%%%%%%%%%%%%%%plot
%skip if shouldn't plot
if ~shouldPlot
    return;
end

figure;
plot(imSub{1}.imaging.yPosBins,100*accuracy,'b','LineWidth',2);
% shadedErrorBar(imSub{1}.imaging.yPosBins,100*accuracy,100*confidenceIntervals,'b');
hold on;
% if shouldShuffle
%     plot(imSub{1}.imaging.yPosBins,100*shuffleAccuracy(lowInd,:),'r:','LineWidth',2);
%     plot(imSub{1}.imaging.yPosBins,100*shuffleAccuracy(highInd,:),'r:','LineWidth',2);
% end
if shouldShuffle
    patchHandle=patch(cat(2,imSub{1}.imaging.yPosBins,fliplr(imSub{1}.imaging.yPosBins)),cat(2,100*shuffleAccuracy(lowInd,:),100*shuffleAccuracy(highInd,:)),[1 0 0]);
    set(patchHandle,'FaceAlpha',0.25,'EdgeColor','r');
end
line([-1000 10000],[50 50],'Color','k','LineStyle','--');
xlim([min(imSub{1}.imaging.yPosBins) max(imSub{1}.imaging.yPosBins)]);
ylim([0 100]);
xlabel('Y Position','FontSize',30);
ylabel('Classifier Accuracy','FontSize',30);
set(gca,'FontSize',20);
titleStr = 'Least distance classifier performance for left vs. right trials in condition ';
for i = 1:length(condition)
    if isnumeric(condition{i})
        titleStr = [titleStr, num2str(condition{i}),' '];
    else
        titleStr = [titleStr, condition{i},' '];
    end
end
%add on segment dividers
for i = 1:length(segRanges)
    line(repmat(segRanges(i),1,2),[0 100],'Color','g','LineStyle','--');
end

title(titleStr,'FontSize',20);

