function plotSimpleTransStats(stats)

nBins = 30;
figH = figure;
axAll = subplot(1,2,1);

%plot histogram 
histAll = histogram(stats.meanFracActive, nBins, 'Normalization','Probability');

beautifyPlot(figH, axAll);

axAll.XLabel.String = 'Fraction of trial active';
axAll.YLabel.String = 'Fraction of neurons';

axCue = subplot(1,2,2);

%plot histogram 
histCue = histogram(stats.meanFracCueActive, nBins, 'Normalization','Probability');

beautifyPlot(figH, axCue);

axCue.XLabel.String = 'Fraction of cue period active';
axCue.YLabel.String = 'Fraction of neurons';
