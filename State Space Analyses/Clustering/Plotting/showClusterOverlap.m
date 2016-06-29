function meanOverlap = showClusterOverlap(dataCell,clusterIDs,cMat,varargin)
%showClusterOverlap.m Shows the overlap in clusters 
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
zThresh = 1;
nShuffles = 200;
minClusterSize = 10;

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
            case 'zthresh'
                zThresh = varargin{argInd+1};
            case 'minclustersize'
                minClusterSize = varargin{argInd+1};
            case 'nshuffles'
                nShuffles = varargin{argInd+1};
        end
    end
end

%% get clustered traces
[overlapIndex, ~,~, ~, totalSize,~] = calculateClusterOverlap(dataCell,clusterIDs,cMat,'sortBy',...
    sortBy,'zThresh',zThresh);
nPoints = length(overlapIndex);
nClusters = cellfun(@length,overlapIndex);

%% get mean off-diagonal
if nargout > 0
    meanOverlap.offDiag = nan(nPoints,1);
    meanOverlap.diag = nan(nPoints,1);
    for point = 1:nPoints
        temp_overlap_offdiag = overlapIndex{point}(logical(tril(ones(size(overlapIndex{point})),-1)));
        temp_overlap_ondiag = diag(overlapIndex{point});
        temp_size_offdiag = totalSize{point}(logical(tril(ones(size(overlapIndex{point})),-1)));
        temp_size_diag = diag(totalSize{point});        
        meanOverlap.offDiag(point) = nanmean(temp_overlap_offdiag(temp_size_offdiag >= minClusterSize));
        meanOverlap.diag(point) = nanmean(temp_overlap_ondiag(temp_size_diag >= minClusterSize));
    end
    
    %shuffle 
    shuffleOffDiag = nan(nShuffles,nPoints);
    shuffleDiag = nan(nShuffles,nPoints);
    parfor shuffleInd = 1:nShuffles
        shuffleIndex = calculateClusterOverlap(dataCell,clusterIDs,cMat,'sortBy',...
            sortBy,'zThresh',zThresh,'shouldShuffle',true);
        for point = 1:nPoints
            shuffleOffDiag(shuffleInd,point) = nanmean(shuffleIndex{point}(logical(tril(ones(size(shuffleIndex{point})),-1))));
            shuffleDiag(shuffleInd,point) = nanmean(diag(shuffleIndex{point}));
        end
        %         dispProgress('Shuffling %d/%d',shuffleInd,shuffleInd,nShuffles);
%         fprintf('Shuffle %d/%d\n',shuffleInd,nShuffles);
    end
    
    %store 
    meanOverlap.shuffleOffDiag = shuffleOffDiag;
    meanOverlap.shuffleDiag = shuffleDiag; 
    return;
end

%% plot 
%create figure
figH = figure;

if showAllPoints
    whichPoints = 1:nPoints;
end
nShowPoints = length(whichPoints);


[nRow,nCol] = calcNSubplotRows(nShowPoints);
for point = 1:nShowPoints
    
    %create subplot
    axH = subplot(nRow,nCol,point);
    
    %show 
    imagescnan(1:nClusters(whichPoints(point)),1:nClusters(whichPoints(point)),...
        overlapIndex{whichPoints(point)},[0 1]);
    
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
cBar.Label.String = 'Overlap index';
cBar.FontSize = 20;
cBar.Label.FontSize = 30;

%label super axes 
supAxes=[.14 .14 .82 .8];
xLab = suplabel('Sorted cluster index','x',supAxes);
xLab.FontSize = 30;
yLab = suplabel('Sorted cluster index','y',supAxes);
yLab.FontSize = 30;
% tLab = suplabel(sprintf('Sorted by %s, zThresh: %.1f',sortBy,zThresh),'t',supAxes);
% tLab.FontSize = 30;




