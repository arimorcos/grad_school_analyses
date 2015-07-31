%create figure
figH = figure;
axH = axes;
hold(axH,'on');

%plot
minVal = min(cat(1,netEvIndAll,shuffleNetEvIndAll));
maxVal = max(cat(1,netEvIndAll,shuffleNetEvIndAll));
nBins = 30;
binEdges = linspace(minVal,maxVal,nBins+1);

%outline version
smooth = false;
histReal = histoutline(netEvIndAll,binEdges,smooth,'Normalization','probability');
histShuffle = histoutline(shuffleNetEvIndAll,binEdges,smooth,'Normalization','probability');
uistack(histReal,'top');
histReal.LineWidth = 2;
histShuffle.LineWidth = 2;
histShuffle.Color = [0.7 0.7 0.7];

%beautify
beautifyPlot(figH,axH);

%label
axH.XLabel.String = 'Net Evidence Selectivity Index';
axH.YLabel.String = 'Fraction of Neurons';

%add legend
legH = legend([histReal, histShuffle],{'Real','Shuffled'},'Location','NorthEast');