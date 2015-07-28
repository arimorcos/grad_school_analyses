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

%cmScale
cmScale = 0.75;
segRanges = segRanges*cmScale;

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%get binned traces
[~,traces] = catBinnedTraces(dataCell);

%subset to trials x bins
traces = squeeze(traces(neuronID,:,:))';

%create a figure
figH = figure;

%get xVals
yPosBins = yPosBins(2:end-1);
traces = traces(:,2:end-1);
xVals = yPosBins*cmScale;


if normAct 
    if min(traces(:)) < 0 
        traces = traces + abs(min(traces(:)));
    end
    traces = traces/max(traces(:));
end

%get number of plots
nPlots = length(conditions);
% [nRows,nCol] = calcNSubplotRows(nPlots);
nRows = 3;
nCol = 1;

%get cLims
cLims = [min(traces(:)) max(traces(:))];

%get mean and sem
meanActivity = nan(nPlots,size(traces,2));
semActivity = nan(nPlots,size(traces,2));

ha = tight_subplot(nRows, nCol, 0.02, 0.04, 0.01);

for plotInd = 1:nPlots
    %     axH = subplot_tight(nRows,nCol,plotInd,[0.04 0.04]);
    axH = ha(plotInd);
    axes(axH);
    
    %get trials which match condition
    matchTrials = findTrials(dataCell,conditions{plotInd});
    
    if plotInd == 1
        shouldSeg = true;
    else
        shouldSeg = false;
    end
    
    makePlot(axH,traces(matchTrials,:),xVals,segRanges,cLims,shouldSeg);
    
    %get mean activity and sem
    meanActivity(plotInd,:) = nanmean(traces(matchTrials,:));
    semActivity(plotInd,:) = calcSEM(traces(matchTrials,:));
    
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
    cBar.Label.String = 'Normalized dF/F';
else
    cBar.Label.String = 'dF/F';
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
    axH.YLabel.String = 'Mean Normalized dF/F';
else
    axH.YLabel.String = 'Mean dF/F';
end
axis(axH,'square');
axH.XLim = [min(xVals) max(xVals)];
axH.FontSize = 20;
axH.LabelFontSizeMultiplier = 1.2;
minY = min(min(meanActivity - semActivity));
maxY = max(max(meanActivity + semActivity));
axH.YLim = [minY - 0.05*(maxY-minY) maxY + 0.05*(maxY-minY)];
axH.XTickLabel = axH.XTick;
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