function meanCorr = showClusterCorrelation(dataCell,clusterIDs,cMat,varargin)
%showClusterCorrelation.m Shows the correlation between clusters
%
%INPUTS
%traces - trace array 
%clusterIDs - clusterIDs output by getClusteredMarkovMatrix
%cMat - CMat output by getClusteredMarkovMatrix
%
%OPTIONAL INPUTS
%pointLabels - point labels 
%sortBy - variable to sort clusters by 
%zThresh - threshold as standard deviations above mean to count as active
%showAllPoints - should show all 
%whichPoints - which points to show if not all
%
%ASM 4/15

pointLabels = {'Maze Start','Segment 1','Segment 2','Segment 3','Segment 4',...
    'Segment 5','Segment 6','Early Delay','Late Delay','Turn'};
sortBy = 'leftTurn';
showAllPoints = true;
whichPoints = 8;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'pointlabels'
                pointLabels = varargin{argInd+1};
            case 'sortby'
                sortBy = varargin{argInd+1};
            case 'showallpoints'
                showAllPoints = varargin{argInd+1};
            case 'whichpoints'
                whichPoints = varargin{argInd+1};
        end
    end
end

%% get clustered traces
clusterCorr = calculateClusterCorrelation(dataCell,clusterIDs,cMat,'sortBy',...
    sortBy);
nPoints = length(clusterCorr);
nClusters = cellfun(@length,clusterCorr);

%% get mean off-diagonal
meanCorr.offDiag = nan(nPoints,1);
meanCorr.diag = nan(nPoints,1);
for point = 1:nPoints
    meanCorr.offDiag(point) = nanmean(clusterCorr{point}(logical(tril(ones(size(clusterCorr{point})),-1))));
    meanCorr.diag(point) = nanmean(diag(clusterCorr{point}));
end

if nargout > 0 
    return;
end

%% plot 
%create figure
figH = figure;

if showAllPoints
    whichPoints = 1:nPoints;
end
nShowPoints = length(whichPoints);

%get min and max correlation
allCorr = cellfun(@(x) x(:),clusterCorr,'UniformOutput',false);
allCorr = cat(1,allCorr{:});
minCorr = min(allCorr);
maxCorr = max(allCorr);

[nRow,nCol] = calcNSubplotRows(nShowPoints);
for point = 1:nShowPoints
    
    %create subplot
    axH = subplot(nRow,nCol,point);
    
    %show 
    imagescnan(1:nClusters(whichPoints(point)),1:nClusters(whichPoints(point)),...
        clusterCorr{whichPoints(point)},[minCorr maxCorr]);
    
    %set ticks 
    axH.XTick = 1:nClusters(whichPoints(point));
    axH.YTick = 1:nClusters(whichPoints(point));
    
    %label axes
    axH.Title.String = pointLabels{whichPoints(point)};
    axH.FontSize = 15;
    axis(axH,'square');
    
end

%create superAxes 
cBarSupAx = [0.1 0.05 0.85 0.9];
supAx = axes('Position',cBarSupAx,'Visible','off');

%add colorbar 
cBar = colorbar;
cBar.Label.String = 'Correlation coefficient';
cBar.FontSize = 20;
cBar.Label.FontSize = 30;
cBar.Limits = [minCorr maxCorr];

%label super axes 
supAxes=[.14 .14 .82 .8];
xLab = suplabel('Sorted cluster index','x',supAxes);
xLab.FontSize = 30;
yLab = suplabel('Sorted cluster index','y',supAxes);
yLab.FontSize = 30;




