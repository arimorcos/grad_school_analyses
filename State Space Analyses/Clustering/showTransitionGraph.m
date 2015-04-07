function showTransitionGraph(mMat,cMat,varargin)
%showTransitionGraph.m Plots a transition graph where each node represents
%a cluster at a given point and each edge represents the transition from
%one cluster to another. Edge width represents the transition probability.
%
%INPUTS
%mMat - mMat output by getClusteredMarkovMatrix
%
%ASM 4/15

sizeScale = 600;
pointLabels = {'Maze Start','Segment 1','Segment 2','Segment 3','Segment 4',...
    'Segment 5','Segment 6','Early Delay','Late Delay','Turn'};
colorBy = 'netEv';
sortBy = colorBy;
modSort = false;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'sizescale'
                sizeScale = varargin{argInd+1};
            case 'pointlabels'
                pointLabels = varargin{argInd+1};
            case 'colorby'
                colorBy = varargin{argInd+1};
                if ~modSort; sortBy = colorBy; end
            case 'sortby'
                sortBy = varargin{argInd+1};
                modSort = true;
        end
    end
end

%get nPoints
nPoints = length(mMat) + 1;

%get nClusters in each point
nClusters = nan(nPoints,1);
nClusters(1) = size(mMat{1},1);
for point = 2:nPoints
    nClusters(point) = size(mMat{point-1},2);
end

%sort points
if ~strcmpi(sortBy,'none') && ~isempty(cMat)
    for point = 1:nPoints
        [~,tempSortOrder] = sort(cMat.(sortBy){point});
        if point < nPoints
            mMat{point} = mMat{point}(tempSortOrder,:);
        end
        if point > 1
            mMat{point-1} = mMat{point-1}(:,tempSortOrder);
        end
        fields = fieldnames(cMat);
        for field = 1:length(fields)
            cMat.(fields{field}){point} = cMat.(fields{field}){point}(tempSortOrder);
        end
    end
end

%create figure
figH = figure;
axH = axes;
hold(axH,'on');

%create scatter array
scatXVals = nan(sum(nClusters),1);
scatYVals = nan(size(scatXVals));
scatSizeData = nan(size(scatXVals));
cumNClusters = cumsum(nClusters);
clusterLoc = cell(nPoints,1);
possiblePositions = linspace(0,1,100);
for point = 1:nPoints
    if point == 1
        clusterInds = 1:nClusters(1);
    else
        clusterInds = cumNClusters(point-1)+1:cumNClusters(point);
    end
    scatXVals(clusterInds) = point;
    
    %set y position
    clusterLoc{point} = possiblePositions(round(linspace(1,length(possiblePositions),nClusters(point)+2)));
    clusterLoc{point} = clusterLoc{point}(2:end-1);
    scatYVals(clusterInds) = clusterLoc{point};
    
    %get size
    if point == 1
        trialFrac = sum(mMat{point},2);
    else
        trialFrac = sum(mMat{point-1});
    end
    scatSizeData(clusterInds) = trialFrac;
end

%create color map
if ~isempty(cMat)
    if isfield(cMat,colorBy)
        values = cat(1,cMat.(colorBy){:});
        valRange = linspace(min(values),max(values),255);
        valDist = bsxfun(@minus,values,valRange);
        [~,ind] = min(abs(valDist),[],2);
        colorPoss = redblue(255);
        colormap(colorPoss);
        colors = colorPoss(ind,:);
        showColorbar = true;
    else
        warning('Cannot interpret colorBy. Coloring uniformly');
        colors = repmat([0 0 1],sum(nClusters),1);
        showColorbar = false;
    end
else
    colors = repmat([0 0 1],sum(nClusters),1);
    showColorbar = false;
end

%set axis properties
axH.YTick = [];
axH.XTickLabel = pointLabels;
axH.XTickLabelRotation = -45;
axH.TickLength = [0 0]; %remove inner ticks
axH.XTick = 1:nPoints;
axH.FontSize = 20;
axH.XLim = [0 nPoints+1];
currYLim = axH.YLim;
axH.YLim = [currYLim(1)-0.025*diff(currYLim) currYLim(2)+0.025*diff(currYLim)];

%add edges
totalWidth = 30;
xOffset = 0;
nEdges = cellfun(@numel,mMat);
maxEdges = max(nEdges);
edgeMat = nan(maxEdges,nPoints-1);
for point = 1:(nPoints-1)
    % get temporary matrix
    tempMat = mMat{point};
    edgeMat(1:numel(tempMat),point) = tempMat(:);
end

%find number which match
nMatch = sum(~isnan(edgeMat(:)));
allEdges = edgeMat(:);
allEdges(isnan(allEdges)) = [];

%initialize
tempXVals = nan(2,nMatch);
tempYVals = nan(size(tempXVals));

%create line plotting matrix
ind = 1;
for point = 1:(nPoints - 1)
    for transition = 1:maxEdges
        if ~isnan(edgeMat(transition,point))
            tempXVals(:,ind) = [point + xOffset; point + 1 - xOffset];
            [xInd, yInd] = ind2sub(size(mMat{point}),transition);
            tempYVals(:,ind) = [clusterLoc{point}(xInd); clusterLoc{point+1}(yInd)];
            ind = ind + 1;
        end
    end
end

%plot
edgeH = line(tempXVals,tempYVals);
% uistack(edgeH,'bottom');
for edge = 1:nMatch
    if allEdges(edge) > 0
        edgeH(edge).Color = 'k';
        edgeH(edge).LineWidth = allEdges(edge)*totalWidth;
    else
        delete(edgeH(edge));
    end
end

%scatter nodes
scatH = scatter(scatXVals,scatYVals,'filled');
scatH.CData = colors;
scatH.MarkerEdgeColor = 'k';
scatH.SizeData = scatSizeData*sizeScale;

%add colorbar
if showColorbar
    cBar = colorbar;
    caxis([min(values) max(values)]);
    cBar.Label.String = colorBy;
end

