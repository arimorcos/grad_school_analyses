function handles = plotMultipleHighwayCorrectFromFolder(folder,fileStr)
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

%get list of files in folder
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array
probIncorrect = cell(length(matchFiles),1);
pVal = nan(length(matchFiles),1);
errorRate = nan(length(matchFiles),1);
nTrials = nan(length(matchFiles),1);
nErrors = nan(length(matchFiles),1);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    probIncorrect{fileInd} = currFileData.probIncorrect;
    pVal(fileInd) = currFileData.pVal;
    errorRate(fileInd) = currFileData.errorRate;
    nErrors(fileInd) = currFileData.nErrors;
    nTrials(fileInd) = currFileData.nTrials;
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
    
    if errorRate(file) < 0.05
        continue;
    end
    
    plotH = plot(1:length(probIncorrect{file}),sort(probIncorrect{file}));
    plotH.Color = colors(file,:);
    plotH.Marker = 'o';
    plotH.MarkerSize = 15;
    plotH.LineStyle = '-';
    plotH.LineWidth = 3;
    if pVal(file) < 0.05
        plotH.MarkerFaceColor = colors(file,:);
    end
end

%set axis to square
axis(handles.ax,'square');

%label axes
handles.ax.YLabel.String = 'Probability Incorrect';
handles.ax.XLabel.String = 'Highway Index';
handles.ax.XLabel.FontSize = 30;
handles.ax.YLabel.FontSize = 30;
handles.ax.FontSize = 20;

%maximize
handles.fig.Units = 'normalized';
handles.fig.OuterPosition = [0 0 1 1];

