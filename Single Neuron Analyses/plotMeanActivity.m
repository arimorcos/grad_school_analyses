function figH = plotMeanActivity(dataCell,conditions,neuronID,conditionTitles)
%plotMeanActivity.m Plots mean activity fora given neuron
%
%INPUTS
%dataCell - dataCell contianing imaging data
%neuronID - neuronID
%
%OUTPUTS
%figH - figure to plot
%
%ASM 5/15

if nargin < 4 || isempty(conditionTitles)
    conditionTitles = conditions;
end

segRanges = 0:80:480;
normAct = true;
zScoreAct = false;

%cmScale
cmScale = 0.75;
segRanges = segRanges*cmScale;

%get yPosBins
useCell = getTrials(dataCell,'maze.numLeft==0,6;result.correct==1');
yPosBins = useCell{1}.imaging.yPosBins;

%get binned traces
% [~,traces] = catBinnedTraces(useCell);
traces = catBinnedDeconvTraces(useCell);

%subset to trials x bins
traces = squeeze(traces(neuronID,:,:))';

%create a figure
figH = figure;

%get xVals
yPosBins = yPosBins(2:end-1);
traces = traces(:,2:end-1);
xVals = yPosBins*cmScale;


origTraces = traces;
if normAct 
    if min(traces(:)) < 0 
        traces = traces + abs(min(traces(:)));
    end
    traces = traces/max(traces(:));
end
% if zScoreAct
%     traces = zScoreTraces(traces);
% end

%get number of plots
nPlots = length(conditions);
% [nRows,nCol] = calcNSubplotRows(nPlots);
nRows = 4;
nCol = 1;

%get cLims
cLims = [min(traces(:)) max(traces(:))];

%get mean and sem
meanActivity = nan(nPlots,size(traces,2));
semActivity = nan(nPlots,size(traces,2));

ha = tight_subplot(nRows, nCol, 0.02, 0.04, 0.01);

colormap(hot);

for plotInd = 1:nPlots
    %     axH = subplot_tight(nRows,nCol,plotInd,[0.04 0.04]);
    axH = ha(plotInd);
    axes(axH);
    
    %get trials which match condition
    matchTrials = findTrials(useCell,conditions{plotInd});
    
    if plotInd == 1
        shouldSeg = true;
    else
        shouldSeg = false;
    end
    
    makePlot(axH,traces(matchTrials,:),xVals,segRanges,cLims,shouldSeg);
    
    %get mean activity and sem
    meanActivity(plotInd,:) = nanmean(origTraces(matchTrials,:));
    semActivity(plotInd,:) = calcSEM(origTraces(matchTrials,:));
    
    %     axH.Title.String = conditionTitles{plotInd};
    %     axH.Title.Position(2) = 4*axH.Title.Position(2);
    %     axH.Title.FontSize = 30;
    
    axH.YLabel.String = conditionTitles{plotInd};
    axH.LabelFontSizeMultiplier = 1.2;
    
    axH.XLabel.String = '';
    axH.XTick = [];
    
    %convert yTick to multipleso f 10
    axH.YTick = 10*(1:floor(sum(matchTrials)/10));
    
end

%add colorbar
cBar = colorbar('Position',[0.6 0.43 0.02 0.5]);
cBar.FontSize = 20;
if normAct
    cBar.Label.String = 'Normalized spike probability';
else
    cBar.Label.String = 'Estimated spike probability';
end

%plot mean
% axH = subplot_tight(nRows,nCol,nPlots+1,[0.04 0.04]);
axH = ha(3);
axes(axH);
hold(axH,'on');
leftPlot = shadedErrorBar(xVals,meanActivity(1,:),semActivity(1,:),'-r');
rightPlot = shadedErrorBar(xVals,meanActivity(2,:),semActivity(2,:),'-b');
axH.XLabel.String = 'Maze Position (cm)';
if normAct
    axH.YLabel.String = 'Mean spike probability';
else
    axH.YLabel.String = 'Mean spike probability';
end
axis(axH,'square');
axH.XLim = [min(xVals) max(xVals)];
axH.FontSize = 20;
axH.LabelFontSizeMultiplier = 1.2;
minY = min(min(meanActivity - semActivity));
maxY = max(max(meanActivity + semActivity));
axH.YLim = [minY - 0.05*(maxY-minY) maxY + 0.05*(maxY-minY)];
axH.XTickLabel = axH.XTick;
try
    axH.YTick = round(100*linspace(axH.YLim(1)+0.01,axH.YLim(2)-0.01,5))/100;
end
axH.YTickLabel = axH.YTick;

%add segment dividers
for segInd = 1:length(segRanges)
    lineH = line([segRanges(segInd) segRanges(segInd)],axH.YLim);
    lineH.Color = 'k';
    lineH.LineStyle = '--';
    lineH.LineWidth = 1.25;
end

%add legend
legH = legend([leftPlot.mainLine rightPlot.mainLine],{'Left 6-0','Right 0-6'},...
    'Position',[0.58 0.24 0.1 0.1]);

beautifyPlot(figH,axH);

%% add net evidence 
plotDFFVsNetEv(dataCell,'cellID',neuronID,'traceType','deconv','figH',figH,'axH',ha(4));
end

function makePlot(axH,traces,xVals,segRanges,cLims,shouldSeg)

%plot
imagescnan(xVals,1:size(traces,1),traces,cLims);

%label
axH.FontSize = 20;
axH.LabelFontSizeMultiplier = 1.5;
axH.XLabel.String = 'Maze Position (cm)';
axH.YLabel.String = 'Trial #';

%add segment dividers
for segInd = 1:length(segRanges)
    lineH = line([segRanges(segInd) segRanges(segInd)],axH.YLim);
    lineH.Color = 'k';
    lineH.LineStyle = '--';
    lineH.LineWidth = 1.25;
end

if shouldSeg
    %add segment label
    segLabel = text(axH.XLim(1),...
        axH.YLim(1) - 0.02*range(axH.YLim),'Segment: ');
    segLabel.FontSize = 20;
    segLabel.HorizontalAlignment = 'Right';
    segLabel.VerticalAlignment = 'Bottom';
    segLabel.FontWeight = 'bold';
    
    %add segment numbers
    for segInd = 1:length(segRanges)-1
        segText = text(mean(segRanges(segInd:segInd+1)),...
            axH.YLim(1) - 0.02*range(axH.YLim),sprintf('%d',segInd));
        segText.HorizontalAlignment = 'Center';
        segText.VerticalAlignment = 'Bottom';
        segText.FontSize = 20;
        segText.FontWeight = 'bold';
    end
end

%square
axis(axH,'square');
end