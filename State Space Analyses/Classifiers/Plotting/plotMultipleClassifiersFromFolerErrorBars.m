function handles = plotMultipleClassifiersFromFolderErrorBars(folder,fileStr,yLab,plotType,xLab,maxValue)
%plotMultipleClassifiersFromFolder.m Plots multiple classifiers based on a
%specific folder path 
%
%INPUTS 
%folder - path to folder 
%fileStr - string to match files to 
%title - title string 
%xLab - x label string 
%yLab - y label string 
%
%OUTPUTS
%handles - structure of handles 
%
%ASM 4/15

cmScale = 0.75;
segRanges = cmScale*(0:80:480);
showLegend = false;
dsamp = 4;

if nargin < 5 || isempty(maxValue)
    maxValue = false;
end
if nargin < 4 || isempty(plotType)
    plotType = 'dashBounds';
end
if nargin < 5 || isempty(xLab)
    xLab = 'Maze Position (cm)';
end
if nargin < 3 || isempty(yLab)
    switch plotType
        case 'zScore'
            yLab = 'Shuffle standard deviations above mean';
        case 'dashBounds'
            yLab = 'Classifier Accuracy';
    end
end

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array 
allAcc = cell(length(matchFiles),1);
allShuffle = cell(size(allAcc));
allxVals = cell(size(allAcc));
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    allAcc{fileInd} = currFileData.accuracy(2:end-2);
    allShuffle{fileInd} = currFileData.shuffleAccuracy(:,2:end-2);
    allxVals{fileInd} = currFileData.yPosBins(2:end-2);
end

%cat accuracy 
minBins = min(cellfun(@length, allAcc));
maxBins = max(cellfun(@length, allAcc));
cropAcc = cellfun(@(x) x(end-minBins+1:end),allAcc,'UniformOutput',false);
cropXVals = cellfun(@(x) x(end-minBins+1:end),allxVals,'UniformOutput',false);
catAcc =cat(2,cropAcc{:})';
catXVals = cat(1,cropXVals{:});
meanXVals = mean(catXVals);
cmScale = 0.75;
meanXVals = meanXVals*cmScale;

% get mean and sem
meanAcc = mean(catAcc);
semAcc = calcSEM(catAcc);

%dsamp
meanXVals = meanXVals(1:dsamp:end);
meanAcc = meanAcc(1:dsamp:end);
semAcc = semAcc(1:dsamp:end);

%create figure 
handles.fig = figure;
handles.ax = axes;

%plot errorbar 
% errH = errorbar(meanXVals,meanAcc,semAcc);
% errH.Marker = 'o';
% errH.MarkerFaceColor = errH.MarkerEdgeColor;
errH = shadedErrorBar(meanXVals,meanAcc,semAcc);
color = [0    0.4470    0.7410];
errH.mainLine.Color = color;
errH.patch.FaceColor = color;
errH.patch.FaceAlpha = 0.3;
errH.edge(1).Color = color;
errH.edge(2).Color = color;

%ylim 
handles.ax.YLim = [0 100];

%add chance line 
handles.chanceLine = line([min(meanXVals) max(meanXVals)],...
    [50 50]);
handles.chanceLine.Color = 'k';
handles.chanceLine.LineStyle = '--';
handles.chanceLine.LineWidth = 2;

%beautify
beautifyPlot(handles.fig,handles.ax);

%label axes 
handles.ax.XLabel.String = xLab;
handles.ax.YLabel.String = yLab;
handles.ax.FontSize = 20;
handles.ax.XLim = [min(cmScale*cat(2,allxVals{:})) max(cmScale*cat(2,allxVals{:}))];

%add segment dividers 
handles.lineH = gobjects(length(segRanges),1);
handles.segText = gobjects(length(segRanges)-1,1);
for segInd = 1:length(segRanges)
    handles.lineH(segInd) = line([segRanges(segInd) segRanges(segInd)],handles.ax.YLim);
    handles.lineH(segInd).Color = 'k';
    handles.lineH(segInd).LineStyle = '--';
end

%add segment label 
handles.segLabel = text(handles.ax.XLim(1),...
        handles.ax.YLim(2) + 0.02*range(handles.ax.YLim),'Segment: ');
handles.segLabel.FontSize = 20;
handles.segLabel.HorizontalAlignment = 'Right';
handles.segLabel.VerticalAlignment = 'Bottom';
handles.segLabel.FontWeight = 'bold';

%add segment numbers
for segInd = 1:length(segRanges)-1
    handles.segText(segInd) = text(mean(segRanges(segInd:segInd+1)),...
        handles.ax.YLim(2) + 0.02*range(handles.ax.YLim),sprintf('%d',segInd));
    handles.segText(segInd).HorizontalAlignment = 'Center';
    handles.segText(segInd).VerticalAlignment = 'Bottom';
    handles.segText(segInd).FontSize = 20;
    handles.segText(segInd).FontWeight = 'bold';
end

%set axis to square
axis(handles.ax,'square');

%maximize 
handles.fig.Units = 'normalized';
handles.fig.OuterPosition = [0 0 1 1];