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
    colorLab = 'Normalized spike probability';
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

colormap(hot);

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
    segRanges = segRanges*cmScale;
    
    %plot
    traces{i} = flipud(traces{i});
    if normInd
<<<<<<< HEAD
        imagesc(binLabels,1:size(traces{i},1),flipud(traces{i}));
=======
        imagesc(binLabels,1:size(traces{i},1),traces{i}, [0, 0.5]);
>>>>>>> 068817252fe7854dec931269ae40082b559c0bfd
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
        line(repmat(segRanges(segRangeInd),1,2),[0 size(traces{i},1)],'Color','w','LineStyle','--');
    end
%     
%     %add segment label
%     segLabel = text(axH.XLim(1),...
%         axH.YLim(1) - 0.02*range(axH.YLim),'Segment: ');
%     segLabel.FontSize = 20;
%     segLabel.HorizontalAlignment = 'Right';
%     segLabel.VerticalAlignment = 'Bottom';
%     segLabel.FontWeight = 'bold';
%     
%     %add segment numbers
%     for segInd = 1:length(segRanges)-1
%         segText = text(mean(segRanges(segInd:segInd+1)),...
%             axH.YLim(1) - 0.02*range(axH.YLim),sprintf('%d',segInd));
%         segText.HorizontalAlignment = 'Center';
%         segText.VerticalAlignment = 'Bottom';
%         segText.FontSize = 20;
%         segText.FontWeight = 'bold';
%     end
    
end

if nTraces == 1;
    axH.FontSize = 20;
    axH.Title.String = '';
    cAxis.Label.FontSize = 30;
end



