function figHandle = plotMultipleBinSubsPCA(dataCell,conditions,nPlots,nDim,binSize)
%plotMultipleBinSubsPCA.m Plots data of the first nDim dimensions in state space
%
%INPUTS
%dataCell - dataCell containing imaging data
%conditions - which conditions to display. If empty, all
%nPlots - number of subsets
%nDim - number of dimensions to display
%binSize - binSize
%
%OUTPUTS
%figHandle - figure handle
%
%ASM 1/14

if nargin < 5 || isempty(binSize) 
    binSize = 15;
end
if nargin < 4 || isempty(nDim) 
    nDim = 3;
end
if nargin < 3 || isempty(nPlots)
    nPlots = 5;
end

%get imSub
imSub = getTrials(dataCell,'imaging.imData == 1');

%bin if necessary
if ~isfield(imSub{1}.imaging,'binnedDFFTraces')
    imSub = binFramesByYPos(imSub,binSize);
end
nBins = length(imSub{1}.imaging.yPosBins);

%determine binRanges
linBins = round(linspace(1,nBins,nPlots+1));
binStart = [1,linBins(2:end-1) + 1];
binStop = linBins(2:end);

%create figure
figHandle = figure;

%determine number of rows and columns
nPlotCol = ceil(nPlots/2);

%loop through each plot and plot
for i = 1:nPlots
    
    %create axis
    axisHandle = subplot(2,nPlotCol,i);
    
    %plot
    plotPCA(dataCell,conditions,nDim,[binStart(i) binStop(i)],binSize,axisHandle);
    
    %title
    title(sprintf('Bins %d to %d',binStart(i),binStop(i)));
    
    if i == 1
        h = legend(axisHandle,conditions);
        pos = get(h,'position');
        set(h,'Position',[0.05 0.45 pos(3:4)]);
    end
end


