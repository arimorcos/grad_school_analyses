function convert_clustered_neurons_to_scatter(oldFig, which_clusters)

keep_cap = true;

%get axis
old_ax = oldFig.Children(2);

%get image 
img = old_ax.Children(2);

%get data 
data = img.CData;

%get cap
cap = oldFig.Children(1).Limits(2);

%cap
if keep_cap
    data(data > cap) = cap;
end

%% plot new 

figH = figure;
axH = axes;
hold(axH, 'on');

if isempty(which_clusters)
    num_clusters = size(data, 2);
    which_clusters = 1:num_clusters;
end

scatH = gobjects(length(which_clusters), 1);
for cluster = 1:length(which_clusters)
    scatH(cluster) = scatter(1:size(data,1), data(:, which_clusters(cluster)));
end

%beautify
beautifyPlot(figH, axH);

%label
axH.XLabel.String = 'Cell number';
axH.YLabel.String = 'z-scored spike count';

legH = legend([scatH(1), scatH(2), scatH(3)], {'Cue 1 sorted', 'Cue 1', 'Cue 2'});





