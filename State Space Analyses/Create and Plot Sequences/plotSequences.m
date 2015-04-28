function figHandle = plotSequences(traces,binLabels,traceLabels,normInd,colorLab,axToPlot)
%plotSequences.m Plots multiple sequences
%
%INPUTS
%traces - 1 x nTraces cell array of traces in a nNeurons x nBins format
%binLabels - 1 x nBins array of labels
%traceLabels - 1 x nTraces cell array of trace labels
%normInd - should normalize individually
%
%OUTPUTS
%figHandle - handle of figure
%
%ASM 1/14

if nargin < 6 || isempty(axToPlot)
    axToPlot = [];
else
    figHandle = axToPlot;
end

if nargin < 5 || isempty(colorLab)
    colorLab = 'Normalized dF/F';
end

segRanges = 0:80:480;

%convert to cell if not cell
if ~iscell(traces)
    traces = {traces};
end
if ~iscell(traceLabels)
    traceLabels = {traceLabels};
end

%create figure
if isempty(axToPlot)
    figHandle = figure;
end

%determine number of traces
nTraces = length(traces);

%determine subplot square size
[nPlotRows,nPlotCol] = calcNSubplotRows(nTraces);


%determine color limits if normalized together
allData = cat(1,traces{:});
cLims = [min(allData(:)) max(allData(:))];


%loop and create subplots
for i = 1:nTraces
    
    %create subplot
    if ~isempty(axToPlot) && nTraces == 1
        axH = axes(axToPlot);
    else
        axH = subplot(nPlotRows,nPlotCol,i);
    end
    
    %scale
    cmScale = 0.75;
    binLabels = cmScale*binLabels;
    
    %plot
    if normInd
        imagesc(binLabels,1:size(traces{i},1),traces{i});
    else
        imagesc(binLabels,1:size(traces{i},1),traces{i},cLims);
    end
    
    %colorbar
    if isempty(axToPlot)
        axH.LabelFontSizeMultiplier = 1.5;
        
        cAxis = colorbar;
        set(get(cAxis,'Label'),'String',colorLab);
        
        %set labels
        xlabel('Maze Position (cm)');
        ylabel('Cell # (sorted)');
        title(traceLabels{i});
        
    end

    
    
    %square
    axis square;
    
    %add on segment dividers
    for segRangeInd = 1:length(segRanges)
        line(repmat(segRanges(segRangeInd),1,2),[0 size(traces{i},1)],'Color','k','LineStyle','--');
    end
    
end

if nTraces == 1;
    axH.FontSize = 20;
    axH.Title.String = '';
    cAxis.Label.FontSize = 30;
end



