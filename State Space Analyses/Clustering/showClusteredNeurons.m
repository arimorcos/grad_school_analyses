function showClusteredNeurons(dataCell,clusterIDs,cMat,varargin)
%showClusteredNeurons.m Shows the average z-scored activity of each neuron
%in each cluster 
%
%INPUTS
%traces - trace array 
%clusterIDs - clusterIDs output by getClusteredMarkovMatrix
%cMat - CMat output by getClusteredMarkovMatrix
%
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
clustTraces = getClusteredNeuronalActivity(dataCell,clusterIDs,cMat,'sortBy',...
    sortBy);
nPoints = length(clustTraces);
nUnique = cellfun(@(x) size(x,2),clustTraces);
nNeurons = size(clustTraces{1},1);


%% plot 
%create figure
figH = figure;

if showAllPoints
    whichPoints = 1:nPoints;
end
nShowPoints = length(whichPoints);

%get min and max value 
% allTraces = cat(2,clustTraces{whichPoints});
% minVal = min(allTraces(:));
% maxVal = max(allTraces(:));

[nRow,nCol] = calcNSubplotRows(nShowPoints);
for point = 1:nShowPoints
    
    %create subplot
    axH = subplot(nRow,nCol,point);
    
    %show 
    imagescnan(1:nUnique(whichPoints(point)),1:nNeurons,clustTraces{whichPoints(point)});
%     imagescnan(1:nUnique(point),1:nNeurons,clustTraces{point},[minVal maxVal]);
    
    %set ticks 
    axH.XTick = 1:nUnique(whichPoints(point));
    
    %label axes
    axH.Title.String = pointLabels{whichPoints(point)};
    cBar = colorbar;
    cBar.Label.String = 'zScore';
    
end

%label super axes 
supAxes=[.14 .14 .78 .8];
xLab = suplabel('Sorted cluster index','x',supAxes);
xLab.FontSize = 30;
yLab = suplabel('Neuron index','y',supAxes);
yLab.FontSize = 30;
tLab = suplabel(sprintf('Sorted by %s',sortBy),'t',supAxes);
tLab.FontSize = 30;




