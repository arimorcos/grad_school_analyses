function plotMultipleCorrectErrorSim(folder,fileStr,use_correlation)
%plotMultipleCorrectErrorSim.m Plots the across epoch
%correlation for clusters vs. the transition probability
%
%ASM 10/15

cmScale = 0.75;
showError = true;

if nargin < 3 || isempty(use_correlation)
    use_correlation = true;
end

%get list of files in folder
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));
nFiles = length(matchFiles);

%loop through each file and create array
allOutCorr = cell(nFiles,1);
allOutCosineSim = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    allOutCorr{fileInd} = currFileData.out_corr;
    allOutCosineSim{fileInd} = currFileData.out_cos_sim;
end

%% combine all 

minBins = min(cellfun(@(x) length(x.yPosBins), allOutCorr));

fields = fieldnames(allOutCorr{1});
for field = 1:length(fields)-2
    
    temp_array = nan(nFiles, minBins);
    for fileInd = 1:nFiles
        if use_correlation
            temp_array(fileInd, :) = allOutCorr{fileInd}.(fields{field}).mean(end-minBins+1:end);
        else
            temp_array(fileInd, :) = allOutCosineSim{fileInd}.(fields{field}).mean(end-minBins+1:end);
        end
    end
    
    out.(fields{field}).mean = nanmean(temp_array);
    out.(fields{field}).sem = calcSEM(temp_array);
end

x_vals = cmScale * allOutCorr{1}.yPosBins(end-minBins+1:end);

%% plot
figH = figure;
axH = axes;
hold(axH, 'on');

which_bins = 2:length(x_vals) - 1;

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
