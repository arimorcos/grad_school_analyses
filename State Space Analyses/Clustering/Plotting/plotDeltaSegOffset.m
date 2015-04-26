function plotDeltaSegOffset(dataCell,whichPlots,binPoints)
%plotDeltaSegOffset.m Plots the delta segment offset
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%ASM 4/15

nSeg = 6;

if nargin < 3 || isempty(binPoints)
    binPoints = true;
end

if nargin < 2 || isempty(whichPlots)
    whichPlots = 1:nSeg;
end

%get traces
[~,traces] = catBinnedTraces(dataCell);

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%get tracePoints
tracePoints = getMazePoints(traces,yPosBins);

%initialize
dists = cell(nSeg+1,1);

%get pairwise distance at each point from maze start to segment 6
for pointInd = 1:nSeg+1
    %get distances at each point
    dists{pointInd} = pdist(squeeze(tracePoints(:,pointInd,:))');
end


%get distances
segDist = tril(squareform(pdist([1:nSeg+1]')));

%loop through each deltaseg
deltaSegStart = cell(nSeg,1);
deltaSegEnd = cell(nSeg,1);
for deltaSeg = 1:nSeg
    %get pairs which match
    [pair1,pair2] = ind2sub(size(segDist),find(segDist == deltaSeg));
    
    %concatenate all those points together
    deltaSegStart{deltaSeg} = cat(2,dists{pair1});
    deltaSegEnd{deltaSeg} = cat(2,dists{pair2});
end

%% plot
figH = figure;
nPlots = length(whichPlots);
[nRows,nCol] = calcNSubplotRows(nPlots);
r2 = nan(nPlots,1);
slope = nan(nPlots,1);

%loop through ecah plot
for plotInd = 1:nPlots
    axH = subplot(nRows,nCol,plotInd);
    %scatter
    if binPoints
        nBins = 25;
        binEdges = linspace(min(deltaSegStart{whichPlots(plotInd)}),...
            max(deltaSegStart{whichPlots(plotInd)}),nBins+1);
        
        %get mean in each bin
        meanEnd = nan(nBins,1);
        semEnd = nan(nBins,1);
        meanStart = binEdges(1:end-1) + diff(binEdges);
        for binInd = 1:nBins
            matchInd = deltaSegStart{whichPlots(plotInd)} >= binEdges(binInd) &...
                deltaSegStart{whichPlots(plotInd)} < binEdges(binInd+1);
            
            meanEnd(binInd) = mean(deltaSegEnd{whichPlots(plotInd)}(matchInd));
            semEnd(binInd) = calcSEM(deltaSegEnd{whichPlots(plotInd)}(matchInd)');
        end
        scatH = errorbar(meanStart,meanEnd,semEnd);
        
        allPoints = cat(1,meanStart',meanEnd);
        lims = [min(allPoints) max(allPoints)];
        
        %fill in markers
        scatH.Marker = 'o';
        scatH.MarkerFaceColor = 'b';
        scatH.LineWidth = 2;
        scatH.Color = 'b';
        scatH.MarkerEdgeColor = 'b';
        scatH.LineStyle = 'none';
    else
        scatH = scatter(deltaSegStart{whichPlots(plotInd)},deltaSegEnd{whichPlots(plotInd)});
        
        allPoints = cat(2,deltaSegStart{whichPlots(plotInd)},deltaSegEnd{whichPlots(plotInd)});
        lims = [min(allPoints) max(allPoints)];
    end
    axis(axH,'square');
    
    
    
    %get allPoints
    axH.XLim = lims;
    axH.YLim = lims;
    hold(axH,'on');
    
    %calculate correlation coefficient
    [corr,pVal] = corrcoef(deltaSegStart{whichPlots(plotInd)},deltaSegEnd{whichPlots(plotInd)});
    textH = text(lims(1)+0.01*range(lims),lims(2)-0.01*range(lims),...
        sprintf('R^{2}: %.3f, p = %.4d',corr(2,1)^2,pVal(2,1)));
    textH.FontSize = 20;
    textH.VerticalAlignment = 'top';
    textH.HorizontalAlignment = 'Left';
    r2(plotInd) = corr(2,1)^2;
    
    %add line of unity
    lineH = line(lims,lims);
    lineH.Color = 'k';
    lineH.LineStyle = '--';
    
    %fit lines and plot
    fitCoeff = robustfit(deltaSegStart{plotInd},deltaSegEnd{plotInd});
    slope(plotInd) =fitCoeff(2);
    
    %title
    axH.Title.String = sprintf('\\Delta%d Segments',whichPlots(plotInd));
    axH.FontSize = 20;
    
end


%label axes
if length(whichPlots) > 1
    yLab = suplabel('End distance (euclidean)','y');
    xLab = suplabel('Start distance (euclidean)','x');
    xLab.FontSize = 30;
    yLab.FontSize = 30;
else
    axH.LabelFontSizeMultiplier = 1.5;
    axH.YLabel.String = 'End distance (euclidean)';
    axH.XLabel.String = 'Start distance (euclidean)';
end
%% summary plot
figH = figure;
axH = axes;

%plot
% [yyH,plotR,plotSlope] = plotyy(1:nPlots,r2,1:nPlots,slope);
plotH = plot(1:nPlots,r2);
plotH.Marker = 'o';
plotH.MarkerSize = 12;
plotH.MarkerFaceColor = plotH.Color;
axis(axH,'square');

%label axes
axH.XTick = 1:nPlots;
axH.XLabel.String = '\Delta Segments';
axH.XLabel.FontSize = 30;

axH.FontSize = 20;
axH.YLabel.FontSize = 30;
axH.YLabel.String = 'R^{2}';
% yyH(1).YLabel.FontSize = 30;
% yyH(2).YLabel.FontSize = 30;
% yyH(1).YLabel.String = 'R^{2}';
% yyH(2).YLabel.String = 'Fit Slope';
% [yyH(:).FontSize] = deal(20);

