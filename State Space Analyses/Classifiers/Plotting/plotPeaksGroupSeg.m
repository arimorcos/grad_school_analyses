function plotPeaksGroupSeg(classifierOut,varargin)
%plotNetEvClassfierGroupSeg.m Plot classifier for all segments
%
%INPUTS
%accuracy - nSeg x nBins array containing accuracy for each bin of each
%   segment
%classGuess - nTrials x nBins x nSeg array of classifier guesses
%realClass - nTrials x nSeg array of actual net evidence
%shuffleAccuracy - nSeg x nBins x nShuffles array containing accuracy for
%   each bin of each segment of each shuffle
%
%OUTPUTS
%figH - 1 x 2 array of figure handles
%
%ASM 9/14

plotShuffle = true;
percRange = [2.5 97.5];
modeOrMean = 'mean';

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'plotshuffle'
                plotShuffle = varargin{argInd+1};
            case 'percrange'
                percRange = varargin{argInd+1};
            case 'modeormean'
                modeOrMean = varargin{argInd+1};
        end
    end
end

%retrieve from classifierOut
accuracy = classifierOut(1).accuracy;
realClass = classifierOut(1).realClass;
classGuess = classifierOut(1).classGuess;
shuffleAccuracy = classifierOut(1).shuffleAccuracy;
shuffleGuess = classifierOut(1).shuffleGuess;

%get number of subsets
nSub = length(classifierOut);


%% plot peak location

%get nBinsPerSeg and nSeg
[~,nBinsPerSeg] = size(accuracy);

uniqueClasses = {};
%get unique classes in each segment
for subInd = 1:nSub
    uniqueClasses{subInd} = unique(classifierOut(subInd).realClass(:));
    nClasses(subInd) = length(uniqueClasses{subInd});
    allClasses{subInd} = uniqueClasses{subInd};
end

%process shuffle
if plotShuffle
    %         %permute shuffleGuess to be nTrials x nSeg x nShuffles
    %         shuffleGuess = permute(shuffleGuess,[1 3 4 2]);
    nShuffles = size(shuffleGuess,3);
end

%get mean guess for each
[meanGuessAll,semGuessAll] = getMeanGuess(nClasses(1),realClass,uniqueClasses{1},...
    nBinsPerSeg,classGuess,modeOrMean);
meanGuessLeft = getMeanGuess(nClasses(2),classifierOut(2).realClass,...
    uniqueClasses{2},nBinsPerSeg,classifierOut(2).classGuess,modeOrMean);
meanGuessRight = getMeanGuess(nClasses(3),classifierOut(3).realClass,...
    uniqueClasses{3},nBinsPerSeg,classifierOut(3).classGuess,modeOrMean);

%get squared error
[allSqError,leftSqError,rightSqError] = calcSqErrorGuess(meanGuessAll,...
    meanGuessLeft,meanGuessRight,allClasses);

%get actual left/right slope
[allSlope,leftSlope,rightSlope] = getRegressionSlope(allClasses,...ve
    meanGuessAll,meanGuessLeft,meanGuessRight);

%loop through each shuffle and get shuffled slopes
if plotShuffle
    shuffleLeftSlope = nan(nShuffles,1);
    shuffleRightSlope = nan(nShuffles,1);
    shuffleAllSlope = nan(nShuffles,1);
    allSqErrorShuffle = nan(nShuffles,1);
    leftSqErrorShuffle = nan(nShuffles,1);
    rightSqErrorShuffle = nan(nShuffles,1);
    for shuffleInd = 1:nShuffles
        
        %get mean guesses
        meanGuessAllShuffle = getMeanGuess(nClasses(1),realClass,uniqueClasses{1},nBinsPerSeg,...
            classifierOut(1).shuffleGuess(:,:,shuffleInd),modeOrMean);
        meanGuessLeftShuffle = getMeanGuess(nClasses(2),classifierOut(2).realClass,...
            uniqueClasses{2},nBinsPerSeg,classifierOut(2).shuffleGuess(:,:,shuffleInd),modeOrMean);
        meanGuessRightShuffle = getMeanGuess(nClasses(3),classifierOut(3).realClass,...
            uniqueClasses{3},nBinsPerSeg,classifierOut(3).shuffleGuess(:,:,shuffleInd),modeOrMean);
        
        %get slopes
        [shuffleAllSlope(shuffleInd),shuffleLeftSlope(shuffleInd),shuffleRightSlope(shuffleInd)] =...
            getRegressionSlope(allClasses,meanGuessAllShuffle,...
            meanGuessLeftShuffle,meanGuessRightShuffle);
        
        %get sqError
        [allSqErrorShuffle(shuffleInd),leftSqErrorShuffle(shuffleInd),rightSqErrorShuffle(shuffleInd)] =...
            calcSqErrorGuess(meanGuessAllShuffle,meanGuessLeftShuffle,...
            meanGuessRightShuffle,allClasses);
        
        %show progress
        dispProgress('Calculating shuffled slope %d/%d',shuffleInd,shuffleInd,nShuffles);
    end
    
    %get percentiles
    allSlopeShufflePerc = prctile(shuffleAllSlope,percRange,1);
    leftSlopeShufflePerc = prctile(shuffleLeftSlope,percRange,1);
    rightSlopeShufflePerc = prctile(shuffleRightSlope,percRange,1);
    allSqErrorShufflePerc = prctile(allSqErrorShuffle,percRange,1);
    leftSqErrorShufflePerc = prctile(leftSqErrorShuffle,percRange,1);
    rightSqErrorShufflePerc = prctile(rightSqErrorShuffle,percRange,1);
end

%create figure
figH = figure;

%plot scatter
subplot(2,2,1);
colorToPlot = 'b';
hold on;
errorbar(uniqueClasses{1},meanGuessAll,semGuessAll,'LineStyle','none',...
    'MarkerSize',10,'Marker','o','MarkerFaceColor',colorToPlot,...
    'MarkerEdgeColor',colorToPlot,'LineWidth',2,'Color',colorToPlot);
xlabel('Actual Condition','FontSize',30);
ylabel('Mean Guess','FontSize',30);
set(gca,'FontSize',15);
axis square;
xlim([min(uniqueClasses{1})-0.5 max(uniqueClasses{1})+0.5]);
ylim([min(uniqueClasses{1})-0.5 max(uniqueClasses{1})+0.5]);
set(gca,'xtick',min(uniqueClasses{1}):2:max(uniqueClasses{1}))

%plot slopes
subplot(2,2,2);
scatter(1:3,[allSlope,leftSlope,rightSlope],'bo','filled','sizedata',120);
hold on;
errorbar(1:3,zeros(1,3),[abs(allSlopeShufflePerc(1)) abs(leftSlopeShufflePerc(1)) ...
    abs(rightSlopeShufflePerc(1))],[allSlopeShufflePerc(2) leftSlopeShufflePerc(2)...
    rightSlopeShufflePerc(2)],'k','LineStyle','None','Marker','o');
set(gca,'xticklabel',{'All','Left','Right'},'xtick',1:3);
ylabel('Slope','FontSize',30);
set(gca,'FontSize',15);
axis square;

%plot squared error
subplot(2,2,3);
scatter(1:3,[allSqError,leftSqError,rightSqError],'bo','filled','sizedata',120);
hold on;
meanAllSq = mean(allSqErrorShufflePerc);
meanLeftSq = mean(leftSqErrorShufflePerc);
meanRightSq = mean(rightSqErrorShufflePerc);
errorbar(1:3,[meanAllSq,meanLeftSq,meanRightSq],...
    [meanAllSq - allSqErrorShufflePerc(1) meanLeftSq - leftSqErrorShufflePerc(1) ...
    meanRightSq - rightSqErrorShufflePerc(1)],...
    [allSqErrorShufflePerc(2)-meanAllSq leftSqErrorShufflePerc(2)-meanLeftSq...
    rightSqErrorShufflePerc(2)-meanRightSq],'k','LineStyle','none','Marker','o');
set(gca,'xticklabel',{'All','Left','Right'},'xtick',1:3);
ylabel('Squared Error','FontSize',30);
set(gca,'FontSize',15);
axis square;

end
function [meanGuess,semGuess] = getMeanGuess(nClasses,realClass,uniqueClasses,nBinsPerSeg,classGuess,modeOrMean)
%initialize medianGuess
meanGuess = nan(1,nClasses);
semGuess = nan(1,nClasses);

%get median peak for each condition and each segment
for condInd = 1:nClasses
    
    %get subset
    tempSub = classGuess(realClass==uniqueClasses(condInd),round(nBinsPerSeg/2));
    
    %continue if empty
    if isempty(tempSub)
        continue;
    end
    
    %get mean guess
    switch(modeOrMean)
        case 'mean'
            meanGuess(condInd) = mean(tempSub);
        case 'mode'
            meanGuess(condInd) = mode(tempSub);
    end
    semGuess(condInd) = std(tempSub)/sqrt(length(tempSub));
    
    
end
end

function [allSlope,leftSlope,rightSlope] = getRegressionSlope(allClasses,...
    meanGuessAll,meanGuessLeft,meanGuessRight)

%loop through each segment and fit regression line to left and right
%conditions, then calculate slope

%fit each with regression
leftModel = fitlm(allClasses{2}(:),meanGuessLeft(:));
rightModel = fitlm(allClasses{3}(:),meanGuessRight(:));
allModel = fitlm(allClasses{1}(:),meanGuessAll(:));

%get slope
leftSlope = leftModel.Coefficients{'x1','Estimate'};
rightSlope = rightModel.Coefficients{'x1','Estimate'};
allSlope = allModel.Coefficients{'x1','Estimate'};
end

function [allSqError,leftSqError,rightSqError] = calcSqErrorGuess(meanGuessAll,...
    meanGuessLeft,meanGuessRight,allClasses)

%do all
absDiff = abs(meanGuessAll(:) - allClasses{1}(:));
sqDiff = absDiff.^2;
allSqError = nansum(sqDiff);

%left
leftAbsDiff = abs(meanGuessLeft(:) - allClasses{2}(:));
leftSqDiff = leftAbsDiff.^2;
leftSqError = nansum(leftSqDiff);

%right
rightAbsDiff = abs(meanGuessRight(:) - allClasses{3}(:));
rightSqDiff = rightAbsDiff.^2;
rightSqError = nansum(rightSqDiff);
end
