function plotMultipleTrialPairOverlapVsFracTrialsClustered(folder,fileStr)
%plotMultipleTrialPairOverlapVsFracTrialsClustered.m Plots the 
%fraction of trial pairs that are still clustered together vs. the 
%fraction of trials that were clustered
%
%ASM 10/15

ind_lines = true;

%get list of files in folder
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));
nFiles = length(matchFiles);

%loop through each file and create array
fracTogether = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    fracTogether{fileInd} = currFileData.fracTogether;
    fracTrials = currFileData.fracTrials;
end

% combine all frac_explored
all_frac_together = cat(1, fracTogether{:});

% take mean and sem 
mean_val = mean(all_frac_together);
sem_val = calcSEM(all_frac_together);

%% plot 
figH = figure;
axH = axes;
hold(axH, 'on');

if ind_lines
    plotH = plot(fracTrials, all_frac_together);
    
    % add mean 
%     meanH = plot(fracTrials, mean_val);
%     meanH.Color = 'k';
%     meanH.LineWidth = 2;
else
    colors = lines(2);
    errH = shadedErrorBar(fracTrials,mean_val, sem_val);
    color = colors(1,:);
    errH.mainLine.Color = color;
    errH.patch.FaceColor = color;
    errH.patch.FaceAlpha = 0.3;
    errH.edge(1).Color = color;
    errH.edge(2).Color = color;
end

%beautify 
beautifyPlot(figH, axH);
axH.YLim = [0 1];

%label 
axH.XLabel.String = 'Fraction of trials clustered';
axH.YLabel.String = 'Fraction of trial pairs still clustered together';
