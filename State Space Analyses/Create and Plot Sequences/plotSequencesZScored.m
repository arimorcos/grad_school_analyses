function figHandle = plotSequencesZScored(traces,binLabels,traceLabels,cLims)
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

segRanges = 0:80:480;

%convert to cell if not cell
if ~iscell(traces)
    traces = {traces};
end
if ~iscell(traceLabels)
    traceLabels = {traceLabels};
end

%create figure
figHandle = figure;

%determine number of traces
nTraces = length(traces);

%determine subplot square size
[nPlotRows,nPlotCol] = calcNSubplotRows(nTraces);

%determine color limits if normalized together
allData = cat(1,traces{:});
if nargin < 4 || isempty(cLims)
    cLims = [min(allData(:)) max(allData(:))];
end


%loop and create subplots
for i = 1:nTraces
    
    %create subplot
    subplot(nPlotRows,nPlotCol,i);
    
    %plot
    imagesc(binLabels,1:size(traces{i},1),traces{i},cLims);
    
    %colorbar
    cAxis = colorbar;
    
    %set labels
    xlabel('Y Position (binned)');
    ylabel('Cell # (sorted)');
    title(traceLabels{i});
    set(get(cAxis,'Label'),'String','zScored dF/F');
    
    %square
    axis square;
    
    %add on segment dividers
    for segRangeInd = 1:length(segRanges)
        line(repmat(segRanges(segRangeInd),1,2),[0 size(traces{i},1)],'Color','k',...
            'LineStyle','--','LineWidth',2);
    end
    
end



