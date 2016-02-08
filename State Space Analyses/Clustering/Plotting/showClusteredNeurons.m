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

pointLabels = {'Maze Start','Cue 1','Cue 2','Cue 3','Cue 4',...
    'Cue 5','Cue 6','Early Delay','Late Delay','Turn'};
whichNeurons = [];
showThresholded = false;
zThresh = 0.2;
sortBy = 'leftTurn';
showAllPoints = false;
whichPoints = 6;
showIndTrials = false;
capActivity = true;
sortTraces = false;
sortTracesBy = 1;
filterNeurons = true;
neuronMinMean = 0.001;
groupEpochs = true;

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
            case 'sorttracesby'
                sortTracesBy = varargin{argInd+1};
            case 'filterneurons'
                filterNeurons = varargin{argInd+1};
            case 'neuronminmean'
                neuronMinMean = varargin{argInd+1};
            case 'groupepochs'
                groupEpochs = varargin{argInd+1};
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
if groupEpochs
    nShowPoints = 1;
else
    nShowPoints = length(whichPoints);
end

[nRow,nCol] = calcNSubplotRows(nShowPoints);
for point = 1:nShowPoints
    
    %create subplot
    axH = subplot(nRow,nCol,point);
    
    %get trace to show
    if groupEpochs
        if showIndTrials
            traceToShow = [];
            epoch_boundaries = nan(length(whichPoints), 1);
            for curr_point = 1:length(whichPoints)
                traceToShow = cat(2, traceToShow, ...
                    trialTraces{whichPoints(curr_point)}(whichNeurons,:));
                epoch_boundaries(curr_point) = size(traceToShow, 2);
            end
            xVal = 1:size(traceToShow,2);
        else
            traceToShow = [];
            epoch_boundaries = nan(length(whichPoints), 1);
            for curr_point = 1:length(whichPoints)
                traceToShow = cat(2, traceToShow, ...
                    clustTraces{whichPoints(curr_point)}(whichNeurons,:));
                epoch_boundaries(curr_point) = size(traceToShow, 2);
            end
            xVal = 1:size(traceToShow,2);
        end
    else
        if showIndTrials
            traceToShow = trialTraces{whichPoints(point)}(whichNeurons,:);
            xVal = 1:size(traceToShow,2);
        else
            traceToShow = clustTraces{whichPoints(point)}(whichNeurons,:);
            xVal = 1:nUnique(whichPoints(point));
        end
    end
    
    % filter neurons 
    if filterNeurons 
        keepNeurons = mean(traceToShow, 2) >= neuronMinMean;
        traceToShow = traceToShow(keepNeurons, :);
    end
    
    %threshold 
    if showThresholded
        traceToShow = double(traceToShow >= zThresh);
    end
    
    %sort traces 
    if sortTraces
        [~, sortOrder] = sort(traceToShow(:, sortTracesBy), 'descend');
        traceToShow = traceToShow(sortOrder, :);
    end
    
    %show
    if capActivity && ~showThresholded
        valRange = [min(traceToShow(:)), zThresh];
        imagescnan(xVal,1:size(traceToShow, 1),traceToShow,valRange);
    else
        imagescnan(xVal,1:size(traceToShow,1),traceToShow);
    end
    
    %if label ytick if necessary
    if size(traceToShow, 1) < 20
        axH.YTick = 1:size(traceToShow, 1);
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
        axH.XTick = 1:size(traceToShow,2);
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
    cBar.TickLabels = num2cell(cBar.Ticks);
    if capActivity
        cBar.TickLabels{end} = sprintf('%s+', cBar.TickLabels{end});
    end
    if nShowPoints < 3
        axH.FontSize = 20;
    end
    axis(axH,'square');
    
    % add epoch divider 
    if groupEpochs
        num_boundaries = length(epoch_boundaries)-1;
        epoch_dividers = gobjects(num_boundaries);
        for boundary = 1:num_boundaries
            epoch_dividers(boundary) = line(...
                0.5 + [epoch_boundaries(boundary), epoch_boundaries(boundary)],...
                axH.YLim, 'Color', 'k', 'LineWidth', 2);
        end
        
        % change title 
%         new_title = '';
%         for curr_point = 1:length(whichPoints)
%             new_title = cat(2, new_title, ' / ', pointLabels{whichPoints(curr_point)});
%         end
        new_title = strjoin(pointLabels(whichPoints), ' / ');
        axH.Title.String = new_title;
    end
    
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




