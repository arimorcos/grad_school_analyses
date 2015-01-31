function plotClassifierOutput(accuracy,shuffleAccuracy,yPosBins,confInt,segRanges)
%plotClassifierOutput.m General function to plot the output of a classifier
%
%INPUTS
%accuracy - 1 x nBins array of accuracy
%shuffleAccuracy - nShuffles x nBins array of shuffle Accuracy
%yPosBins - bin labels
%confInt - confidence intervals
%
%ASM 1/15

if nargin < 5 || isempty(segRanges)
    segRanges = 0:80:480;
end
if nargin < 4 || isempty(confInt)
    confInt = 95;
end

%create figure
figH = figure;
axH = axes;
hold(axH,'on');

%plot accuracy
accPlot = plot(yPosBins,accuracy);
accPlot.Color = 'b';
accPlot.LineWidth = 2;

%plot shuffle
if ~isempty(shuffleAccuracy)
    
    %get nShuffles
    nShuffles = size(shuffleAccuracy,1);
    
    %determine confidence interval range
    lowConf = (100 - confInt)/2;
    highConf = 100 - lowConf;
    
    %get confidence intervals
    shuffleMedian = median(shuffleAccuracy);
    confidenceIntervals = prctile(shuffleAccuracy,[highConf,lowConf]);
    confidenceIntervals = abs(bsxfun(@minus,confidenceIntervals,shuffleMedian));
    
    %plot shuffle
    shuffleH = shadedErrorBar(yPosBins,shuffleMedian,confidenceIntervals);
    shuffleH.patch.FaceAlpha = 0.2;
    shuffleH.patch.FaceColor = 'r';
    shuffleH.mainLine.Color = 'r';
end

%plot chance line
line([-1000 10000],[50 50],'Color','k','LineStyle','--');

%set limits
axH.XLim = [min(yPosBins) max(yPosBins)];
axH.YLim = [0 100];

%label axes
axH.XLabel.String = 'Y Position (binned)';
axH.YLabel.String = 'Classifier Accuracy';

%set axes overall size
axH.FontSize = 20;

%add on segment dividers
for i = 1:length(segRanges)
    line(repmat(segRanges(i),1,2),[0 100],'Color','k','LineStyle','--');
end