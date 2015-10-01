% plot 
figH = figure;
axH = axes;
hold(axH,'on');
minVal = min(cat(1,netEvCorr,meanShuffleCorr));
maxVal = max(cat(1,netEvCorr,meanShuffleCorr));
nBins = 30;
binEdges = linspace(minVal,maxVal,nBins+1);

%shaded version

%outline version
smooth = false;
histReal = histoutline(netEvCorr,binEdges,smooth,'Normalization','probability');
histShuffle = histoutline(meanShuffleCorr,binEdges,smooth,'Normalization','probability');
uistack(histReal,'top');
histReal.LineWidth = 2;
histShuffle.LineWidth = 2;
histShuffle.Color = [0.7 0.7 0.7];

%beautify
beautifyPlot(figH,axH);

%label
axH.XLabel.String = 'Net evidence correlation';
axH.YLabel.String = 'Fraction of neurons';

%add legend
legH = legend([histReal, histShuffle],{'Real','Shuffled'},'Location','NorthEast');