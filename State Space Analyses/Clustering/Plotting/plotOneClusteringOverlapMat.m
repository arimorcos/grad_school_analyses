function plotOneClusteringOverlapMat(overlapIndex)

% create figure and ax 
figH = figure;
axH = axes;

%plot 
imagescnan(overlapIndex);

%beautify
beautifyPlot(figH,axH);

%label 
axH.XLabel.String = 'Cluster index';
axH.YLabel.String = 'Cluster index';

%colorbar 
cBar = colorbar;
cBar.FontSize = 20;
cBar.Label.String = 'Overlap Index';
cBar.Label.FontSize = 30;