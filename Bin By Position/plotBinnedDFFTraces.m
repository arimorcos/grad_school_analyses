function plotBinnedDFFTraces(dFFTraces,yPosBins,showError,labels,maxRows,cellIDs)
%plotDFFTraces.m Plots dF/F traces and can plot image of all cells with
%cell number and filters overlaid
%
%INPUTS
%dFFTraces - nCells x nFrames x nTrials array of dF/F traces generated by
%   getDFFTraces.m. If cell array, can plot multiple subsets with labels
%yPosBins - 1 x nBins array containing the y positions corresponding to
%   each bin
%showError - show shaded error bar with standard deviation
%labels - labels of different dFF traces
%cellIDs - array of cellIDs to plot. If empty, all.
%maxRows - maximum number of rows
%
%ASM 10/13

if ~iscell(dFFTraces)
    dFFTraces = {dFFTraces};
end

if nargin < 5 || isempty(maxRows)
    maxRows = 10;
end
if nargin < 4 || isempty(labels)
    labels = repmat('',1,length(dFFTraces));
end
if nargin < 3 || isempty(showError)
    showError = true;
end

%get nCells and nFrames
[nCellsAll,nFrames] = size(dFFTraces{1});

%populate cellIDs
if nargin < 6 || isempty(cellIDs)
    cellIDs = 1:nCellsAll;
    nCells = nCellsAll;
else
    nCells = length(cellIDs);
end

%get nDatasets
nDatasets = length(dFFTraces);

%initialize
axesHandles = gobjects(1,nCells);
plotHandles = cell(nDatasets,nCells);
figH = figure('Name','dF/F Traces');

%calculate subplot size
if nCells > maxRows
    nCol = ceil(nCells/maxRows);
    nRows = maxRows;
else
    nCol = 1;
    nRows = nCells;
end

colors = distinguishable_colors(nDatasets);

for i = 1:nDatasets
    
    %get minimum value in cells to plot
    minVal = min(min(dFFTraces{i}(cellIDs,:)));
    
    if size(dFFTraces{i},3) == 1 
        showErrorDataset = false;
    elseif size(dFFTraces{i},3) > 1 && showError
        showErrorDataset = true;
    end
    
    %plot dF/F each cells
    for j = 1:nCells %for each cell
        
        %get subplot ind
        [rowInd,colInd] = ind2sub([nRows,nCol],j);
        plotInd = sub2ind([nCol,nRows],colInd,rowInd);
        
        %create subplot
        axesHandles(j) = subplot(nRows,nCol,plotInd);
        
        %plot fluorescence trace
        if showErrorDataset
            plotHandles{i,j} = shadedErrorBar(yPosBins,mean(dFFTraces{i}(cellIDs(j),:,:),3),...
                std(dFFTraces{i}(cellIDs(j),:,:),0,3),{'color',colors(i,:)});
        else
            plotHandles{i,j} = plot(yPosBins,mean(dFFTraces{i}(cellIDs(j),:),3));
        end
        
        %clear xTickLabel if not at bottom of a column
        if mod(j,nRows) ~= 0 && j ~= nCells
            set(axesHandles(j),'XTickLabel','');
        end
        
        %set yLim
        set(axesHandles(j),'ylim',[minVal 1.1*max(dFFTraces{i}(cellIDs(j),:))]);
        
        
        %set title
        text(1.01,0.5,sprintf('%d',cellIDs(j)),'FontWeight','Bold',...
            'Units','Normalized','FontSize',20,...
            'HorizontalAlignment','Left',...
            'VerticalAlignment','Middle');
        
    end

end

set(axesHandles(:),'FontSize',14);

%set axes labels
[~,xLabHand] = suplabel('Y Position','x');
[~,yLabHand] = suplabel('%dF/F','y');
set([xLabHand, yLabHand], 'FontSize',25);