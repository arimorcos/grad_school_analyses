function plotMultiplePCADim(folder,fileStr, use_var)
%plotMultipleClusteredDimensionality.m Plots the across epoch
%correlation for clusters vs. the transition probability
%
%ASM 10/15

%normalize
normalize = ~true;
show_error = true;

%get list of files in folder
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));
nFiles = length(matchFiles);

%loop through each file and create array
dim = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    dim{fileInd} = currFileData.dim;
    which_var = currFileData.which_var;
end

%% filter var
use_var_ind = which_var == use_var;
if ~any(use_var_ind)
    error('Must set correct variance');
end

%cat dim
dim_all = cat(3, dim{:});
dim = squeeze(dim_all(use_var_ind, :, :));

if normalize
    %get total dim
    total_dim = squeeze(dim_all(which_var == 100, 1, :));
    dim = bsxfun(@rdivide, dim, total_dim');
end

%% plot
figH = figure;
axH = axes;
hold(axH, 'on');

if show_error
    errH = shadedErrorBar(1:10,mean(dim'),calcSEM(dim'));
    color = [0    0 0];
    errH.mainLine.Color = color;
    errH.patch.FaceColor = color;
    errH.patch.FaceAlpha = 0.3;
    errH.edge(1).Color = color;
    errH.edge(2).Color = color;
else
    plotH = plot(1:10, dim);
end

%beautify
beautifyPlot(figH, axH);
axH.XLim = [0.8 10.2];
% axH.YLim = [0 1];

%label
axH.XLabel.String = 'Maze epoch';
if normalize
    axH.YLabel.String = sprintf('Fraction of dimensions to reach %d%% variance', use_var);
else
    axH.YLabel.String = sprintf('Number of dimensions to reach %d%% variance', use_var);
end