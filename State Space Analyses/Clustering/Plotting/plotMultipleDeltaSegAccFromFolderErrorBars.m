function handles = plotMultipleDeltaSegAccFromFolder(folder,fileStr)
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
nDelta = 9;

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array 
nSTD = nan(length(matchFiles),2*nDelta+1);
nUnique = nan(length(matchFiles),1);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    nSTD(fileInd,:) = currFileData.deltaPoint.meanNSTD;
    nUnique(fileInd) = currFileData.nUnique;
end
save(fullfile(folder,strrep(fileStr,'.*','')),'nUnique');

%nFiles
nFiles = length(matchFiles);

handles.fig = figure;
handles.ax = axes;

%hold
hold(handles.ax,'on');

colors = distinguishable_colors(nFiles);

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
meanVals = nanmean(nSTD);
semVals = calcSEM(nSTD);
errH = shadedErrorBar(xVals,meanVals,semVals);
color = [0    0.4470    0.7410];
errH.mainLine.Color = color;
errH.patch.FaceColor = color;
errH.patch.FaceAlpha = 0.3;
errH.edge(1).Color = color;
errH.edge(2).Color = color;

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

