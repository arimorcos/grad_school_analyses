function figHandle = plotPCA(dataCell,conditions,nDim,binRange,binSize,currAxes)
%plotPCA.m Plots data of the first nDim dimensions in state space
%
%INPUTS
%dataCell - dataCell containing imaging data
%conditions - which conditions to display. If empty, all
%nDim - number of dimensions to display
%binRange - range of bins to display. If less than 1, rounded percentages.
%   If empty, all
%binSize - binSize
%currAxes - axes on which to plot
%
%OUTPUTS
%figHandle - figure handle
%
%ASM 1/14

if nargin < 6 
    currAxes = [];
end
if nargin < 5 || isempty(binSize)
    binSize = 15;
end
if nargin < 4
    binRange = [];
end
if nargin < 3 || isempty(nDim)
    nDim = 2;
end
if nargin < 2 || isempty(conditions)
    conditions = [];
end

%get imSub
imSub = getTrials(dataCell,'imaging.imData == 1');

%bin if necessary
if ~isfield(imSub{1}.imaging,'binnedDFFTraces')
    imSub = binFramesByYPos(imSub,binSize);
end

%get number of bins
nBins = length(imSub{1}.imaging.yPosBins);

%get neuronal traces
[~,PCATraces] = catBinnedTraces(imSub,1);

%crop unused dimensions
PCATraces = PCATraces(1:nDim,:,:);

%crop bins
if ~isempty(binRange) %skip if no bin range
    if any(binRange < 1) %if any are less than 1
        binRange = round(binRange*nBins); %multiply by nBins
        binRange = max(binRange,1); %remove zero values
    end
    PCATraces = PCATraces(:,binRange(1):binRange(2),:);
end

%take mean position across binRange
meanPosPCA = squeeze(nanmean(PCATraces,2));

%get groups 
groups = nan(1,length(imSub));
for i = 1:max(1,length(conditions))
    groups(findTrials(imSub,conditions{i})) = i;
end
 

%create figure
if isempty(currAxes)
    figHandle = figure;
else
    axis(currAxes);
end

%plot
h = gscatter(meanPosPCA(1,:),meanPosPCA(2,:),groups,[],[],30,'off');
axis square;
xlabel('PC 1');
ylabel('PC 2');
if isempty(currAxes)
    legend(conditions,'Location','EastOutside');
end
if nDim == 3
    groupNames = unique(groups);
    for k = 1:sum(~isnan(groupNames))
        set(h(k),'ZData',meanPosPCA(3,groups == groupNames(k)));
    end
    view(3);
    zlabel('PC 3');
end
