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
whichNeurons = [];
showThresholded = false;
zThresh = 0.5;
sortBy = 'leftTurn';
showAllPoints = true;
whichPoints = 8;
showIndTrials = false;
capActivity = true;
sortTraces = false;

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
            case 'whichneurons'
                whichNeurons = varargin{argInd+1};
            case 'showthresholded'
                showThresholded = varargin{argInd+1};
            case 'showindtrials'
                showIndTrials = varargin{argInd+1};
            case 'zthresh'
                zThresh = varargin{argInd+1};
            case 'capactivity'
                capActivity = varargin{argInd+1};  
            case 'sorttraces'
                sortTraces = varargin{argInd+1};
        end
    end
end

%% get clustered traces
[clustTraces,trialTraces,clustCounts] = getClusteredNeuronalActivity(dataCell,clusterIDs,cMat,'sortBy',...
    sortBy);
nPoints = length(clustTraces);
nUnique = cellfun(@(x) size(x,2),clustTraces);
nNeurons = size(clustTraces{1},1);
if isempty(whichNeurons)
    whichNeurons = 1:nNeurons;
end


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
    
    %get trace to show
    if showIndTrials
        traceToShow = trialTraces{whichPoints(point)}(whichNeurons,:);
        xVal = 1:size(traceToShow,2);
    else
        traceToShow = clustTraces{whichPoints(point)}(whichNeurons,:);
        xVal = 1:nUnique(whichPoints(point));
    end
    if showThresholded
        traceToShow = double(traceToShow >= zThresh);
    end
    
    %sort traces 
    if sortTraces
        totalDiff = sum(abs(diff(clustTraces{whichPoints(point)}(whichNeurons,:),1,2)),2);
        [~,sortOrder] = sort(totalDiff,'descend');
        traceToShow = traceToShow(sortOrder,:);
    end
    
    %show
    if capActivity
        valRange = prctile(traceToShow(:),[2.5 97.5]);
        imagescnan(xVal,1:length(whichNeurons),traceToShow,valRange);
    else
        imagescnan(xVal,1:length(whichNeurons),traceToShow);
    end
    %     imagescnan(1:nUnique(point),1:nNeurons,clustTraces{point},[minVal maxVal]);
    
    %if label ytick if necessary
    if length(whichNeurons) < 20
        axH.YTick = 1:length(whichNeurons);
    end
    
    %add lines
    if showIndTrials
        hold(axH,'on');
        cumCounts = cumsum(clustCounts{point});
        for sepInd = 1:(length(cumCounts)-1)
            lineH = line(repmat(cumCounts(sepInd)+0.5,2,1),axH.YLim);
            lineH.Color = 'k';
            lineH.LineWidth = 4;
        end
    end
    
    %set ticks
    if showIndTrials
        xTickArray = cat(1,cumCounts(1)/2,cumCounts(1:end-1)+diff(cumCounts)/2) + 0.5;
        axH.XTick = xTickArray;
        axH.XTickLabel = 1:nUnique(whichPoints(point));
    else
        axH.XTick = 1:nUnique(whichPoints(point));
    end
    
    %label axes
    axH.Title.String = pointLabels{whichPoints(point)};
    cBar = colorbar;
    if ~showThresholded
        cBar.Label.String = 'zScored Activity';
    else
        cBar.Ticks = [0 1];
        colormap(parula(2));
        cBar.TickLabels = {'Below Threshold','Above Threshold'};
        cBar.FontSize = 20;
    end
    if nShowPoints < 3
        axH.FontSize = 20;
    end
    axis(axH,'square');
    
end

%label super axes
supAxes=[.14 .14 .78 .81];
if nShowPoints > 1
    yLab = suplabel('Neuron index','y',supAxes);
    yLab.FontSize = 30;
    xLab = suplabel('Sorted cluster index','x',supAxes);
    xLab.FontSize = 30;
else
    axH.YLabel.String = 'Neuron Index';
    axH.LabelFontSizeMultiplier = 1.5;
    axH.XLabel.String = 'Sorted Cluster Index';
end
% tLab = suplabel(sprintf('Sorted by %s',sortBy),'t',supAxes);
% tLab.FontSize = 30;

maxfig(figH,1);




