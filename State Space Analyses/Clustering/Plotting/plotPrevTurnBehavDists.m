function plotPrevTurnBehavDists(out,whichPoints)
%plotPrevTurnBehavDists.m Plots sorted distribution of behavior for each
%point asked for 
%
%INPUTS
%out - 1 x 10 struct array of outputs of clusterBehavDistribution
%whichPoints - whichPoints to plot 
%
%OUTPUTS
%
%ASM 8/15

pointLabels = {'Trial start','Cue 1','Cue 2','Cue 3','Cue 4',...
    'Cue 5','Cue 6','Early delay','Late delay','Turn'};

%create figure
figH = figure;
axH = axes;
hold(axH, 'on');

%get nBins 
nBins = 5;

%loop through and plot 
plotH = gobjects(length(whichPoints),1);
colors = lines(length(whichPoints));
clusterThresh = 5;
for point = 1:length(whichPoints)
    
    %get fraction 
    frac = out(whichPoints(point)).clusterVarCount./out(whichPoints(point)).uniqueCount;
    
    %remove les than clusterThresh 
    keepInd = out(whichPoints(point)).uniqueCount >= clusterThresh;
    frac = frac(keepInd);
    
    %nClusters 
    nClusters = length(frac);
    
    %sort 
    frac = sort(frac);
    
    %bin 
    edges = nClusters/nBins;
    
    %take mean 
    binFrac = nan(nBins,1);
    for i = 1:nBins
        binFrac(i) = mean(frac(floor(edges*(i-1))+1:floor(edges*i)));
    end
    
    %plot 
    plotH(point) = plot(1:nBins,binFrac);
    plotH(point).Color = colors(point,:);
    

end

%beautify
beautifyPlot(figH,axH);

%labels 
axH.XLabel.String = 'Binned cluster number';
axH.YLabel.String = 'Fraction previous left turns';
axH.XTick = 1:nBins;

%legend 
legH = legend(plotH,pointLabels(whichPoints),'Location','NorthWest');