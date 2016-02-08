function [fig1, fig2] = plotPairwiseClusterDistances(dataCell, clusterIDs, cMat,sortBy,plotPoint)
%plotClusterDistances.m Calculates the distances between clusters and sorts
%by a given variable 
%
%INPUTS
%clusterCenters - nPoints x 1 cell array each containing a nNeurons x
%   num_clusters array of clusterCenters
%cMat - structure containing cluster labels for different properties
%sortBy - variable to sort base on
%plotPoint - point to plot
%
%ASM 4/15

min_trials = 10;

pointLabels = {'Trial Start','Cue 1','Cue 2','Cue 3','Cue 4',...
    'Cue 5','Cue 6','Early Delay','Late Delay','Turn'};


% get cluster traces
[~,trialTraces,clustCounts] = ...
    getClusteredNeuronalActivity(dataCell,clusterIDs,cMat);

% subset to relevant point
trialTraces = trialTraces{plotPoint};
clustCounts = clustCounts{plotPoint};

% get number of clusters 
num_clusters = length(clustCounts);

% which clusters 
clust_trials = nan(num_clusters, 2);
for cluster = 1:num_clusters
    if cluster == 1
        clust_trials(cluster, 1) = 1;
    else
        clust_trials(cluster, 1) = sum(clustCounts(1:cluster-1)) + 1;
    end
    clust_trials(cluster, 2) = sum(clustCounts(1:cluster));
end

% loop through each cluster and calculate distance 
dist_cell = cell(num_clusters, num_clusters);
for cluster_1 = 1:num_clusters 
    for cluster_2 = cluster_1:num_clusters
        
        % check that both clusters are above trial threshold 
        if clustCounts(cluster_1) < min_trials || ...
                clustCounts(cluster_2) < min_trials 
            continue
        end
        
        % check if intra or inter 
        if cluster_1 == cluster_2 % intra 
            % do pdist  
            dist_cell{cluster_1, cluster_2} = pdist(...
                trialTraces(:, clust_trials(cluster_1, 1):clust_trials(cluster_1, 2))');
        else
            sub_1 = trialTraces(:, clust_trials(cluster_1, 1):clust_trials(cluster_1, 2));
            sub_2 = trialTraces(:, clust_trials(cluster_2, 1):clust_trials(cluster_2, 2));
            dist_cell{cluster_1, cluster_2} = reshape(pdist2(sub_1', sub_2'), 1, []);
            dist_cell{cluster_2, cluster_1} = dist_cell{cluster_1, cluster_2};
        end     
    end
end

%sort points
if ~strcmpi(sortBy,'none') && ~isempty(cMat)
    [clusterVals,tempSortOrder] = sort(cMat.(sortBy){plotPoint});
    dist_cell = dist_cell(tempSortOrder,tempSortOrder);
    clustCounts = clustCounts(tempSortOrder);
end


%subset 
dist_cell = dist_cell(clustCounts >= min_trials, clustCounts >= min_trials);
num_clusters = length(dist_cell);
clusterVals = clusterVals(clustCounts >= min_trials);

% calculate means 
mean_dist = cellfun(@nanmean, dist_cell);

%% plot distance matrix 
%create figure
fig1 = figure;
axH = axes;

%plot imagesc 
distPlot = imagesc(1:num_clusters,1:num_clusters,mean_dist);
axH.XTick = 1:num_clusters;
axH.YTick = 1:num_clusters;
axH.XTickLabel = clusterVals;
axH.YTickLabel = clusterVals;
axH.XTickLabelRotation = -45;
axH.FontSize = 20;
axH.LabelFontSizeMultiplier = 1.5;

% fix if net ev 
if strcmpi(sortBy, 'netev')
    new_labels = cell(num_clusters, 1);
    for tick = 1:num_clusters
        if clusterVals(tick) > 0
            new_labels{tick} = sprintf('%.1fL', abs(clusterVals(tick)));
        else
            new_labels{tick} = sprintf('%.1fR', abs(clusterVals(tick)));
        end            
    end
    axH.XTickLabel = new_labels;
    axH.YTickLabel = new_labels;
end

% fix if leftTurn 

if strcmpi(sortBy, 'leftTurn')
    new_labels = cell(num_clusters, 1);
    for tick = 1:num_clusters
        new_labels{tick} = sprintf('%.2f', abs(clusterVals(tick)));
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
cluster_val_dist = pdist2(clusterVals, clusterVals);
cluster_val_dist = cluster_val_dist(:);
mean_dist = mean_dist(:);

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
