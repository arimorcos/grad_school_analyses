function showTransitionGraph(mMat,cMat,varargin)
%showTransitionGraph.m Plots a transition graph where each node represents
%a cluster at a given point and each edge represents the transition from
%one cluster to another. Edge width represents the transition probability.
%
%INPUTS
%mMat - mMat output by getClusteredMarkovMatrix
%cMat - color matrix containing information about each node with regards to
%   behavioral variables
%
%OPTIONAL INPUTS
%sizeScale - scale for node sizes.
%pointLabels - xLabels for maze positions
%colorBy - variable to color everything by. Must match field in cMat.
%sortBy - variable to sort by. Must match field in cMat.
%whichPoints - whichPoints to plot. Must be scalar or array.
%showEdges - boolean of whether or not to show edges.
%showNull - boolean of whether or not to show null probability transitions.
%showTrials - array of which individual trial numbers to show. If empty, shows transition
%   probabilities.
%clusterIDs - nTrials x nPoints array of clusterIDs if showing individual
%   trials.
%
%ASM 4/15

% call one clustering version if necessary
if strcmpi(cMat.mode, 'one')
    showTransitionGraphOneClustering(mMat, cMat, varargin{:});
    return;
end

sizeScale = 2000;
totalWidth = 30;
% sizeScale = 600;
pointLabels = {'Trial Start','Cue 1','Cue 2','Cue 3','Cue 4',...
    'Cue 5','Cue 6','Early Delay','Late Delay','Turn'};
colorBy = 'netEv';
sortBy = colorBy;
modSort = false;
showEdges = true;
whichPoints = 1:10;
showNull = false;
showTrial = [];
clusterIDs = [];
trialColors = [];
mMatColors = [];

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'sizescale'
                sizeScale = varargin{argInd+1};
            case 'totalwidth'
                totalWidth = varargin{argInd+1};
            case 'pointlabels'
                pointLabels = varargin{argInd+1};
            case 'colorby'
                colorBy = varargin{argInd+1};
                if ~modSort; sortBy = colorBy; end
            case 'sortby'
                sortBy = varargin{argInd+1};
                modSort = true;
            case 'showedges'
                showEdges = varargin{argInd+1};
            case 'whichpoints'
                whichPoints = varargin{argInd+1};
            case 'shownull'
                showNull = varargin{argInd+1};
            case 'showtrial'
                showTrial = varargin{argInd+1};
            case 'clusterids'
                clusterIDs = varargin{argInd+1};
            case 'trialcolors'
                trialColors = varargin{argInd+1};
            case 'mmatcolors'
                mMatColors = varargin{argInd+1};
        end
    end
end

%get nPoints
nPoints = length(cMat.netEv);

%get nClusters in each point
% nClusters = nan(nPoints,1);
% nClusters(1) = size(mMat{1},1);
% for point = 2:nPoints
%     nClusters(point) = size(mMat{point-1},2);
% end
nClusters = cellfun(@length,cMat.netEv);

%split mMat
nMMatCol = size(mMat,2);

%sort points
if ~strcmpi(sortBy,'none') && ~isempty(cMat)
    if ~isempty(clusterIDs)
        sortedClusters = cell(nPoints,1);
    end
    for point = 1:nPoints
        [~,tempSortOrder] = sort(cMat.(sortBy){point});
        for col = 1:nMMatCol
            if point < nPoints
                mMat{point,col} = mMat{point,col}(tempSortOrder,:);
            end
            if point > 1
                mMat{point-1,col} = mMat{point-1,col}(:,tempSortOrder);
            end
        end
        fields = fieldnames(cMat);
        for field = 1:length(fields)
            if ismember(fields{field},{'dPoints','mode'})
                continue;
            end
            cMat.(fields{field}){point} = cMat.(fields{field}){point}(tempSortOrder);
        end
        if ~isempty(clusterIDs)
            uniqueClusters = unique(clusterIDs(:,point));
            sortedClusters{point} = uniqueClusters(tempSortOrder);
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
    %     if point == 1
    %         trialFrac = sum(mMat{point},2);
    %     else
    %         trialFrac = sum(mMat{point-1});
    %     end
    trialFrac = cMat.counts{point}/sum(cMat.counts{point});
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
        actualColorPoss = colorPoss;
        if length(unique(values)) == 1 && values(1) == 1
            ind(:) = 255;
        end
        colors = actualColorPoss(ind,:);
        showColorbar = true;
    else
        if ~strcmpi(colorBy,'none')
            warning('Cannot interpret colorBy. Coloring uniformly');
        end
        colors = repmat([1 1 1],sum(nClusters),1);
        showColorbar = false;
    end
else
    colors = repmat([0 0 1],sum(nClusters),1);
    showColorbar = false;
end

%set axis properties
axH.YTick = [];
axH.XTickLabel = pointLabels(whichPoints);
axH.XTickLabelRotation = -45;
axH.TickLength = [0 0]; %remove inner ticks
axH.XTick = whichPoints;
axH.FontSize = 20;
axH.XLim = [whichPoints(1) - 1 whichPoints(end) + 1];
currYLim = axH.YLim;
axH.YLim = [currYLim(1)-0.025*diff(currYLim) currYLim(2)+0.025*diff(currYLim)];

if ~isempty(showTrial)
    showEdges = false;
    if isempty(trialColors)
        trialColors = lines(length(showTrial));
    end
    for trial = 1:length(showTrial)
        currTrial = clusterIDs(showTrial(trial),:);
        for transition = 1:nPoints-1
            startID = currTrial(transition) == sortedClusters{transition};
            endID = currTrial(transition+1) == sortedClusters{transition+1};
            lineH = line([transition transition+1],...
                [clusterLoc{transition}(startID) clusterLoc{transition+1}(endID)]);
            lineH.LineWidth = 3;
            lineH.Color = trialColors(trial,:);
            if trialColors(trial,1)
                lineH.LineStyle = '--';
            end
        end
    end
end

if showEdges
    if nMMatCol > 1 
        yOffset = [0.002, -0.002];
        if isempty(mMatColors)
            edgeColors = lines(2);
        else
            edgeColors = mMatColors;
        end
    else
        yOffset = 0;
        edgeColors = 'k';
    end
    for col = 1:nMMatCol
        addEdges(mMat(:,col),nPoints,whichPoints,clusterLoc,showNull,totalWidth,edgeColors(col,:),yOffset(col));
    end
end

%scatter nodes
keepInd = ismember(scatXVals, whichPoints);
scatH = scatter(scatXVals(keepInd),scatYVals(keepInd),'filled');
scatH.CData = colors(keepInd,:);
scatH.MarkerEdgeColor = 'k';
% scatSizeData(keepInd) = [0.5 1.5 0.5 1.5 0.75 1.25 0.8 1.4];
scatH.SizeData = scatSizeData(keepInd)*sizeScale;

%add colorbar
if showColorbar
    cBar = colorbar;
    if length(unique(values)) > 1
        caxis([min(values) max(values)]);
    end
    cBar.Label.String = colorBy;
end

%mazimieze
figH.Units = 'normalized';
figH.OuterPosition = [0 0 1 1];

end

function addEdges(mMat,nPoints,whichPoints,clusterLoc,showNull,totalWidth,color,yOffset)
%add edges
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
for point = whichPoints(1):whichPoints(end-1)
    for transition = 1:maxEdges
        if ~isnan(edgeMat(transition,point))
            tempXVals(:,ind) = [point + xOffset; point + 1 - xOffset];
            [xInd, yInd] = ind2sub(size(mMat{point}),transition);
            tempYVals(:,ind) = [clusterLoc{point}(xInd)+yOffset; clusterLoc{point+1}(yInd)+yOffset];
            ind = ind + 1;
        end
    end
end

%plot
edgeH = line(tempXVals,tempYVals);
% uistack(edgeH,'bottom');
for edge = 1:nMatch
    if showNull
        edgeH(edge).Color = color;
        nodeInd = edgeH(edge).XData(1) == scatXVals &...
            edgeH(edge).YData(1) == scatYVals;
        nNext = sum(edgeH(edge).XData(1) == scatXVals);
        if any(nodeInd)
            edgeH(edge).LineWidth = scatSizeData(nodeInd)*totalWidth/nNext;
        end
    else
        if allEdges(edge) > 0
            edgeH(edge).Color = color;
            edgeH(edge).LineWidth = allEdges(edge)*totalWidth;
        else
            delete(edgeH(edge));
        end
    end
    
    %         edgeH(edge).Color = 'k';
    %         edgeH(edge).LineWidth = 0.2*rand*totalWidth;
end
end
