% plot 
figH = figure;
axH = axes;
hold(axH,'on');
minVal = min(cat(1,peakAcc,meanShuffleAcc));
% minVal = 48;
maxVal = max(cat(1,peakAcc,meanShuffleAcc));
nBins = 17;
maxVal = 60;
binEdges = linspace(minVal,maxVal,nBins+1);
binEdges(end) = 100;

%shaded version

%outline version
smooth = false;
histReal = histoutline(peakAcc,binEdges,smooth,'Normalization','probability');
histShuffle = histoutline(meanShuffleAcc,binEdges,smooth,'Normalization','probability');
uistack(histReal,'top');
histReal.LineWidth = 2;
histShuffle.LineWidth = 2;
histShuffle.Color = [0.7 0.7 0.7];

axH.XLim = [minVal maxVal];

%beautify
beautifyPlot(figH,axH);

%label
axH.XLabel.String = 'Turn classification accuracy';
axH.YLabel.String = 'Fraction of neurons';

%add legend
legH = legend([histReal, histShuffle],{'Real','Shuffled'},'Location','NorthEast');

% axH.XLim = [49.5 60];