function plot_correct_error_cosine_sim(out)

showError = false;
cmScale = 0.75;

figH = figure;
axH = axes;
hold(axH, 'on');

x_vals = cmScale*out.yPosBins;
out = rmfield(out, 'yPosBins');
use_correlation = out.use_correlation;
out = rmfield(out, 'use_correlation');
which_bins = 5:length(x_vals) - 5;

fields = fieldnames(out);

% show_fields = 1:length(fields);
show_fields = [1:2, 6:9];
colors = distinguishable_colors(length(fields));
leg_handles = gobjects(length(fields), 1);
for field = 1:length(fields)
    
    if ~ismember(field, show_fields)
        continue;
    end
    
    if showError
        errH = shadedErrorBar(x_vals(which_bins),...
            out.(fields{field}).mean(which_bins),...
            out.(fields{field}).sem(which_bins));
        color = colors(field,:);
        errH.mainLine.Color = color;
        errH.patch.FaceColor = color;
        errH.patch.FaceAlpha = 0.3;
        errH.edge(1).Color = color;
        errH.edge(2).Color = color;
        leg_handles(field) = errH.mainLine;
    else
        plotH = plot(x_vals(which_bins),...
            out.(fields{field}).mean(which_bins));
        plotH.Color = colors(field,:);
        plotH.LineWidth = 2;
        leg_handles(field) = plotH;
    end
end

% add cue markers 
ranges = 0:80:480;
ranges = cmScale*ranges;
for i = 1:7
    lineH = line([ranges(i), ranges(i)], axH.YLim);
    lineH.Color = [0.7 0.7 0.7];
    lineH.LineStyle = '--';
end

beautifyPlot(figH, axH);

axH.XLabel.String = 'Maze position (cm)';
axH.XLim = [min(x_vals(which_bins)), max(x_vals(which_bins))];
if use_correlation
    axH.YLabel.String = 'Population correlation';
else
    axH.YLabel.String = 'Cosine similarity';
end
fields = cellfun(@(x) strrep(x, '_', '\_'), fields, 'UniformOutput', false);
legH = legend(leg_handles(show_fields), ...
    fields(show_fields), 'Location', 'BestOutside'); 