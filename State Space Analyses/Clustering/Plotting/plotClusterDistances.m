function [fig1, fig2] = plotClusterDistances(clusterCenters,cMat,sortBy,plotPoint)
%plotClusterDistances.m Calculates the distances between clusters and sorts
%by a given variable 
%
%INPUTS
%clusterCenters - nPoints x 1 cell array each containing a nNeurons x
%   nClusters array of clusterCenters
%cMat - structure containing cluster labels for different properties
%sortBy - variable to sort base on
%plotPoint - point to plot
%
%ASM 4/15

min_trials = 10;

pointLabels = {'Maze Start','Cue 1','Cue 2','Cue 3','Cue 4',...
    'Cue 5','Cue 6','Early Delay','Late Delay','Turn'};
nPoints = length(clusterCenters);

% filter
trial_counts = cMat.counts{plotPoint};
keep_ind = trial_counts >= min_trials;
cMat.(sortBy){plotPoint} = cMat.(sortBy){plotPoint}(keep_ind);
clusterCenters{plotPoint} = clusterCenters{plotPoint}(:, keep_ind);

%sort points
if ~strcmpi(sortBy,'none') && ~isempty(cMat)
    clusterVals = cell(nPoints,1);
    for point = 1:nPoints
        [clusterVals{point},tempSortOrder] = sort(cMat.(sortBy){point});
        clusterCenters{point} = clusterCenters{point}(:,tempSortOrder);
    end
end

%calculate distance
distMat = squareform(pdist(clusterCenters{plotPoint}'));
nClusters = length(distMat);

%% plot fig 1
%create figure
fig1 = figure;
axH = axes;

%plot imagesc 
distPlot = imagesc(1:nClusters,1:nClusters,distMat);
axH.XTick = 1:nClusters;
axH.YTick = 1:nClusters;
axH.XTickLabel = clusterVals{plotPoint};
axH.YTickLabel = clusterVals{plotPoint};
axH.XTickLabelRotation = -45;
axH.FontSize = 20;
axH.LabelFontSizeMultiplier = 1.5;

% fix if net ev 
if strcmpi(sortBy, 'netev')
    new_labels = cell(nClusters, 1);
    for tick = 1:nClusters
        if clusterVals{plotPoint}(tick) > 0
            new_labels{tick} = sprintf('%.1fL', abs(clusterVals{plotPoint}(tick)));
        else
            new_labels{tick} = sprintf('%.1fR', abs(clusterVals{plotPoint}(tick)));
        end            
    end
    axH.XTickLabel = new_labels;
    axH.YTickLabel = new_labels;
end

% fix if leftTurn 

if strcmpi(sortBy, 'leftTurn')
    new_labels = cell(nClusters, 1);
    for tick = 1:nClusters
        new_labels{tick} = sprintf('%.2f', abs(clusterVals{plotPoint}(tick)));
    end
    axH.XTickLabel = new_labels;
    axH.YTickLabel = new_labels;
end

%label 
axH.XLabel.String = sortBy;
axH.YLabel.String = sortBy;
axH.Title.String = pointLabels{plotPoint};
axis(axH,'square');

%add colorbar 
cBar = colorbar;
cBar.Label.String = 'Euclidean distance';
cBar.Label.FontSize = 30;

maxfig(fig1, 1);

%% plot collapsed matrix 

% collapse data 
cluster_val_dist = pdist2(clusterVals{plotPoint}, clusterVals{plotPoint});
cluster_val_dist = cluster_val_dist(:);
mean_dist = distMat(:);

%plot scatter 
fig2 = figure;
axH = axes;
hold(axH, 'on');

scatH = scatter(cluster_val_dist, mean_dist);

% add trendline 
xVals = min(axH.XLim, min(cluster_val_dist)):0.01:max(axH.XLim, max(cluster_val_dist));
mdl = fitlm(cluster_val_dist, mean_dist);
predictions = mdl.predict(xVals');
trendH = plot(xVals, predictions, 'k');

%beautify
beautifyPlot(fig2, axH);

%label 
axH.XLabel.String = sprintf('\\Delta %s', sortBy);
axH.YLabel.String = 'Mean pairwise euclidean distance';

% print significance 
[corr, p] = corrcoef(cluster_val_dist, mean_dist);
sig_str = sprintf('Correlation: %.3f | p: %.5f', corr(1,2), p(1,2));
textH = text(axH.XLim(1) + 0.05*diff(axH.XLim), axH.YLim(2) - 0.1*diff(axH.YLim),...
    sig_str);
textH.HorizontalAlignment = 'left';
textH.VerticalAlignment = 'top';