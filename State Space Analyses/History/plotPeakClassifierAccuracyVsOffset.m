function plotPeakClassifierAccuracyVsOffset(traces,realClass)
%plotPeakClassifierAccuracyVsOffset.m Plots the peak classification
%accuracy vs the degree of offset 
%
%INPUTS
%traces - nNeurons x nBins x nTrials array of traces
%realClass - 1 x nTrials array of class for each trial. Each value should
%
%ASM 1/15

%ensure that traces has the same length as realClass
assert(size(traces,3)==length(realClass),'class and traces must have same number of trials');

%% calculate accuracies

%get nBins
nBins = size(traces,2);

%generate offsets
offsets = -nBins+2:nBins-2;

%loop through each offset and calculate peak accuracy 
offsetAcc = nan(size(offsets));
for offsetInd = 1:length(offsets)
    
    %display progress
    dispProgress('Calculating offset accuracy %d/%d',offsetInd,offsetInd,...
        length(offsets));
    
    %calculate overall accuracy
    tempAcc = getClassifierAccuracyNew(traces,realClass,'testOffset',...
        offsets(offsetInd));
    
    %determine peak accuracy
    offsetAcc(offsetInd) = max(tempAcc);
end

%% plot 

%create figure
figure;
axH = axes;

%set axes font size 
axH.FontSize = 20;

%plot 
plotH = plot(offsets,offsetAcc);
plotH.LineWidth = 2;

%label axes
axH.XLabel.String = 'Bin Offset';
axH.XLabel.FontSize = 25;
axH.YLabel.String = 'Peak Classifier Accuracy';
axH.YLabel.FontSize = 25;

%set limits
axH.XLim = [min(offsets) max(offsets)];

%maximize figure
maxfig(gcf,1);

%%%%%add arrows 
center = axescoord2figurecoord(0,0);
futureH = annotation('textarrow',[center+0.1 center+0.3],[0.04 0.04],...
    'String','Future  ');
futureH.FontSize = 20;
pastH = annotation('textarrow',[center-0.1 center-0.3],[0.04 0.04],...
    'String','  Past');
pastH.FontSize = 20;
    