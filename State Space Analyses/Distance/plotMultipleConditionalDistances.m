function plotMultipleConditionalDistances(folder,fileStr, which_point)
%plotMultipleConditionalDistances.m Plots multiple conditional distances
%
%INPUTS
%folder - folder to search in
%fileStr - file string to match
%
%ASM 2/16

plot_cosine = ~true;

if nargin < 3 || isempty(which_point)
    which_point = 5;
end
pointLabels = {'Trial Start','Cue 1','Cue 2','Cue 3','Cue 4',...
    'Cue 5','Cue 6','Early Delay','Late Delay','Turn'};
plot_multiple = length(which_point) > 1;

%get list of files in folder
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%get nDset
nDatasets = length(matchFiles);

%loop through each file and create array
allOut = cell(nDatasets,1);
for fileInd = 1:nDatasets
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    allOut{fileInd} = currFileData.out;
end

% get condition labels
cond_labels = allOut{1}.conditions;
cond_labels = {'All correct trials',...
    'Same choice',...
    'Same 6-0 choice', ...
    '6-0, curr & prev choice',...
    '6-0, curr & prev choice/reward'};
num_conditions = length(cond_labels);

% concatenate each variable
all_variance = cellfun(@(x) x.mean_variance, allOut, 'uniformoutput', false);
all_variance = cat(3, all_variance{:});

all_distance = cellfun(@(x) x.mean_distance, allOut, 'uniformoutput', false);
all_distance = cat(3, all_distance{:});

all_cosine_distance = cellfun(@(x) x.mean_cosine_distance, allOut, 'uniformoutput', false);
all_cosine_distance = cat(3, all_cosine_distance{:});

all_corr = cellfun(@(x) x.mean_correlation, allOut, 'uniformoutput', false);
all_corr = cat(3, all_corr{:});

% normalize each variable
all_variance = bsxfun(@rdivide, all_variance, all_variance(:, 1, :));
all_distance = bsxfun(@rdivide, all_distance, all_distance(:, 1, :));
all_cosine_distance = bsxfun(@rdivide, all_cosine_distance, all_cosine_distance(:, 1, :));

% take mean and error for each
mean_variance = nanmean(all_variance, 3);
sem_variance = calcSEM(all_variance, 3);

mean_distance = nanmean(all_distance, 3);
sem_distance = calcSEM(all_distance, 3);

mean_cosine_distance = nanmean(all_cosine_distance, 3);
sem_cosine_distance = calcSEM(all_cosine_distance, 3);

% calculate sig
p_val = nan(10, num_conditions, num_conditions);
for point = which_point
    for cond_1 = 1:num_conditions
        for cond_2 = cond_1+1:num_conditions
            if plot_cosine
                [~, p_val(point, cond_1, cond_2)] = ttest2(...
                    all_cosine_distance(point, cond_1, :),...
                    all_cosine_distance(point, cond_2, :));
            else
                [~, p_val(point, cond_1, cond_2)] = ttest2(...
                    all_distance(point, cond_1, :),...
                    all_distance(point, cond_2, :));
            end
        end
    end
end

%create figure
figH = figure;
axH = axes;
hold(axH,'on');

if ~plot_multiple
    % plot
    marker = 'o';
    scat_var = errorbar(0.8:1:num_conditions-0.2, mean_variance(which_point, :),...
        sem_variance(which_point, :));
    scat_var.Marker = marker;
    scat_var.LineStyle = 'none';
    scat_var.LineWidth = 2;
    scat_var.MarkerSize = 20;
    scat_var.MarkerFaceColor = scat_var.MarkerEdgeColor;
    
    scat_dist = errorbar(1:1:num_conditions, mean_distance(which_point, :),...
        sem_distance(which_point, :));
    scat_dist.Marker = marker;
    scat_dist.LineStyle = 'none';
    scat_dist.LineWidth = 2;
    scat_dist.MarkerSize = 20;
    scat_dist.MarkerFaceColor = scat_dist.MarkerEdgeColor;
    
    scat_cosine = errorbar(1.2:1:num_conditions+0.2, mean_cosine_distance(which_point, :),...
        sem_cosine_distance(which_point, :));
    scat_cosine.Marker = marker;
    scat_cosine.LineStyle = 'none';
    scat_cosine.LineWidth = 2;
    scat_cosine.MarkerSize = 20;
    scat_cosine.MarkerFaceColor = scat_cosine.MarkerEdgeColor;
    
    
    % label
    beautifyPlot(figH, axH);
    axH.XTick = 1:num_conditions;
    axH.XTickLabels = cond_labels;
    axH.XTickLabelRotation = -45;
    axH.Title.String = pointLabels{which_point};
    
    legH = legend([scat_var, scat_dist, scat_cosine], ...
        {'Variance', 'Mean pairwise Euclidean distance',...
        'Mean pairwise cosine distance'},...
        'Location', 'Southwest');
else
    % plot
    marker = '.';
    num_plot = length(which_point);
    scat_h = gobjects(num_plot, 1);
    offsets = linspace(-0.2, 0.2, num_plot);
    
    for plot_ind = 1:num_plot
        x_vals = 1+offsets(plot_ind):1:num_conditions+offsets(plot_ind);
        if plot_cosine
            scat_h(plot_ind) = errorbar(x_vals, ...
                mean_cosine_distance(which_point(plot_ind), :),...
                sem_cosine_distance(which_point(plot_ind), :));
        else
            scat_h(plot_ind) = errorbar(x_vals, ...
                mean_distance(which_point(plot_ind), :),...
                sem_cosine_distance(which_point(plot_ind), :));
        end
        scat_h(plot_ind).Marker = marker;
        scat_h(plot_ind).LineStyle = 'none';
        scat_h(plot_ind).LineWidth = 2;
        scat_h(plot_ind).MarkerSize = 20;
        scat_h(plot_ind).MarkerFaceColor = scat_h(plot_ind).MarkerEdgeColor;
    end
    
    % label
    beautifyPlot(figH, axH);
    axH.XTick = 1:num_conditions;
    axH.XTickLabels = cond_labels;
    axH.XTickLabelRotation = -45;
    if plot_cosine
        axH.YLabel.String = 'Cosine distance';
    else
        axH.YLabel.String = 'Euclidean distance';
    end
    
    legH = legend(scat_h, ...
        pointLabels(which_point),...
        'Location', 'Southwest');
end

% print sig
for plot_ind = which_point
    for cond_1 = 1:num_conditions
        for cond_2 = cond_1+1:num_conditions
            if p_val(plot_ind, cond_1, cond_2) <= 0.05
                fprintf('Epoch: %11s | cond_1: %d | cond_2: %d, p: %.4f\n',...
                    pointLabels{plot_ind}, cond_1, cond_2, ...
                    p_val(plot_ind, cond_1, cond_2));
            end
        end
    end
end
