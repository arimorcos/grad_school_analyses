function handles = ...
    plotMultipleDeltaSegAccWithShuffleFromFolderErrorBars(folder,fileStr)
%plotMultipleDeltaSegAccWithShuffleFromFolderErrorBars.m Plots multiple 
%delta seg offset significance from folder with shuffle trial labels
%
%INPUTS 
%folder - path to folder 
%fileStr - string to match files to 
%
%OUTPUTS
%handles - structure of handles 
%
%ASM 10/15
nDelta = 9;

%% get shuffle 
%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array 
nSTDShuffle = nan(length(matchFiles),2*nDelta+1);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    nSTDShuffle(fileInd,:) = currFileData.deltaPointShuffle.meanNSTD;
end

%% get real 

folder = '/Users/arimorcos/Data/Analyzed Data/150904_vogel_deconv_deltaPoint';
fileStr = '.*deconv_10.mat';

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array 
nSTDReal = nan(length(matchFiles),2*nDelta+1);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    nSTDReal(fileInd,:) = currFileData.deltaPoint.meanNSTD;
end
% save(fullfile(folder,strrep(fileStr,'.*','')),'nUnique');

%nFiles
nFiles = length(matchFiles);

handles.fig = figure;
handles.ax = axes;

%hold
hold(handles.ax,'on');

colors = lines(2);

%loop through and plot
% for file = 1:nFiles
%     plotH = plot(1:nDelta,nSTD(file,:));
%     plotH.Color = colors(file,:);
%     plotH.LineWidth = 2;
%     plotH.Marker = 'o';
%     plotH.MarkerFaceColor = colors(file,:);
%     
% end
xVals = -nDelta:nDelta;
meanVals = nanmean(nSTDReal);
semVals = calcSEM(nSTDReal);
errH = shadedErrorBar(xVals,meanVals,semVals);
errH.mainLine.Color = colors(1,:);
errH.patch.FaceColor = colors(1,:);
errH.patch.FaceAlpha = 0.3;
errH.edge(1).Color = colors(1,:);
errH.edge(2).Color = colors(1,:);

%plot shuffle 
meanVals = nanmean(nSTDShuffle);
semVals = calcSEM(nSTDShuffle);
errHShuffle = shadedErrorBar(xVals,meanVals,semVals);
errHShuffle.mainLine.Color = colors(2,:);
errHShuffle.patch.FaceColor = colors(2,:);
errHShuffle.patch.FaceAlpha = 0.3;
errHShuffle.edge(1).Color = colors(2,:);
errHShuffle.edge(2).Color = colors(2,:);

%add chance line 
chanceH = line([-nDelta nDelta],[2 2]);
chanceH.LineStyle = '--';
chanceH.Color = 'k';

%set axis to square
axis(handles.ax,'square');

%label axes
handles.ax.XLabel.String = '\Delta Maze Epochs';
handles.ax.YLabel.String = 'Number STD Above Chance';
handles.ax.XLabel.FontSize = 30;
handles.ax.YLabel.FontSize = 30;
handles.ax.FontSize = 20;
% handles.ax.XTick = -nDelta:nDelta;
handles.ax.XLim = [-nDelta nDelta];

%maximize
handles.fig.Units = 'normalized';
handles.fig.OuterPosition = [0 0 1 1];

%legend 
legend([errH.mainLine, errHShuffle.mainLine],...
    {'Real','Shuffle trial association'},'Location','NorthEast');

