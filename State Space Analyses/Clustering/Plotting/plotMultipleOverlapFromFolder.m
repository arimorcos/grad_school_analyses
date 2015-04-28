function handles = plotMultipleOverlapFromFolder(folder,fileStr,correlation)
%plotMultipleDeltaSegFromFolder.m Plots multiple delta seg offset
%significance from folder
%
%INPUTS 
%folder - path to folder 
%fileStr - string to match files to 
%
%OUTPUTS
%handles - structure of handles 
%
%ASM 4/15

if nargin < 3 || isempty(correlation)
    correlation = false;
end

pointLabels = {'Maze Start','Segment 1','Segment 2','Segment 3','Segment 4',...
    'Segment 5','Segment 6','Early Delay','Late Delay','Turn'};
nPoints = 10;

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array 
plotData = nan(length(matchFiles),nPoints);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    field = fieldnames(currFileData);
    plotData(fileInd,:) = currFileData.(field{1});  
end

%nFiles
nFiles = length(matchFiles);

%create figure and axes
handles.fig = figure;
handles.ax = axes;

%hold 
hold(handles.ax,'on');

%generate colors
colors = distinguishable_colors(nFiles);

%loop through and plot 
for file = 1:nFiles
    plotH = plot(1:nPoints,plotData(file,:));
    plotH.Color = colors(file,:);
    plotH.Marker = 'o';
    plotH.MarkerSize = 10;
    plotH.LineWidth = 2;
    plotH.MarkerFaceColor = colors(file,:);
end

%set axis to square
axis(handles.ax,'square');

%label axes 
handles.ax.XTickLabel = pointLabels;
handles.ax.XTickLabelRotation = -45;
if correlation
    handles.ax.YLabel.String = 'Mean Pairwise Correlation Coefficient';
else
    handles.ax.YLabel.String = 'Mean Pairwise Overlap Index';
end
handles.ax.XLabel.FontSize = 30;
handles.ax.YLabel.FontSize = 30;
handles.ax.FontSize = 20;
handles.ax.XTick = 1:nPoints;
handles.ax.XLim = [0.5 nPoints + 0.5];
handles.ax.YLim = [0 1];

%maximize 
handles.fig.Units = 'normalized';
handles.fig.OuterPosition = [0 0 1 1];

