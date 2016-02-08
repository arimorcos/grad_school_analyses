function plotMultipleClusteredDimensionality(folder,fileStr)
%plotMultipleClusteredDimensionality.m Plots the across epoch
%correlation for clusters vs. the transition probability
%
%ASM 10/15

%get list of files in folder
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));
nFiles = length(matchFiles);

%loop through each file and create array
allOut = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    allOut{fileInd} = currFileData.out;
end

% combine all frac_explored
all_frac_explored = cellfun(@(x) x.frac_explored', allOut, 'UniformOutput', false);
all_frac_explored = cat(1, all_frac_explored{:});

% take mean and sem 
mean_val = mean(all_frac_explored);
sem_val = calcSEM(all_frac_explored);

%% plot 
figH = figure;
axH = axes;

colors = lines(2);
errH = shadedErrorBar(1:10,mean_val, sem_val);
color = colors(1,:);
errH.mainLine.Color = color;
errH.patch.FaceColor = color;
errH.patch.FaceAlpha = 0.3;
errH.edge(1).Color = color;
errH.edge(2).Color = color;

%beautify 
beautifyPlot(figH, axH);
axH.XLim = [0.8 10.2];
axH.YLim = [0 1];

%label 
axH.XLabel.String = 'Maze point';
axH.YLabel.String = 'Fraction of total clusters visited';
