function handles = plotMultipleTrialTypeSVM(folder,fileStr)
%plotMultipleTrialTypeSVM.m Plots multiple classifiers based on a
%specific folder path 
%
%INPUTS 
%folder - path to folder 
%fileStr - string to match files to 
%
%OUTPUTS
%handles - structure of handles 
%
%ASM 4/15

cmScale = 0.75;
segRanges = cmScale*(0:80:480);
dsamp = 4;

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array 
all60 = cell(length(matchFiles),1);
all51 = cell(length(matchFiles),1);
all42 = cell(length(matchFiles),1);
allxVals = cell(length(matchFiles),1);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    all60{fileInd} = currFileData.accuracy_60(2:end-2);
    all51{fileInd} = currFileData.accuracy_51(2:end-2);
    all42{fileInd} = currFileData.accuracy_42(2:end-2);
    allxVals{fileInd} = currFileData.yPosBins(2:end-2);
end

%cat accuracy 
minBins = min(cellfun(@length, all60));
maxBins = max(cellfun(@length, all60));
cropAcc60 = cellfun(@(x) x(end-minBins+1:end),all60,'UniformOutput',false);
cropAcc51 = cellfun(@(x) x(end-minBins+1:end),all51,'UniformOutput',false);
cropAcc42 = cellfun(@(x) x(end-minBins+1:end),all42,'UniformOutput',false);
cropXVals = cellfun(@(x) x(end-minBins+1:end),allxVals,'UniformOutput',false);
catAcc60 =cat(2,cropAcc60{:})';
catAcc51 =cat(2,cropAcc51{:})';
catAcc42 =cat(2,cropAcc42{:})';
catXVals = cat(1,cropXVals{:});
meanXVals = mean(catXVals);
cmScale = 0.75;
meanXVals = meanXVals*cmScale;

% get mean and sem
meanAcc60 = mean(catAcc60);
semAcc60 = calcSEM(catAcc60);
meanAcc51 = mean(catAcc51);
semAcc51 = calcSEM(catAcc51);
meanAcc42 = mean(catAcc42);
semAcc42 = calcSEM(catAcc42);

%dsamp
meanXVals = meanXVals(1:dsamp:end);
meanAcc60 = meanAcc60(1:dsamp:end);
semAcc60 = semAcc60(1:dsamp:end);
meanAcc51 = meanAcc51(1:dsamp:end);
semAcc51 = semAcc51(1:dsamp:end);
meanAcc42 = meanAcc42(1:dsamp:end);
semAcc42 = semAcc42(1:dsamp:end);

%create figure 
handles.fig = figure;
handles.ax = axes;

hold(handles.ax, 'on');

colors = lines(3);

%plot 6-0
err60 = shadedErrorBar(meanXVals, meanAcc60 ,semAcc60);
err60.mainLine.Color = colors(1,:);
err60.patch.FaceColor = colors(1,:);
err60.patch.FaceAlpha = 0.3;
err60.edge(1).Color = colors(1,:);
err60.edge(2).Color = colors(1,:);

%plot 5-1
err51 = shadedErrorBar(meanXVals, meanAcc51 ,semAcc51);
err51.mainLine.Color = colors(2,:);
err51.patch.FaceColor = colors(2,:);
err51.patch.FaceAlpha = 0.3;
err51.edge(1).Color = colors(2,:);
err51.edge(2).Color = colors(2,:);

%plot 4-2
err42 = shadedErrorBar(meanXVals, meanAcc42 ,semAcc42);
err42.mainLine.Color = colors(3,:);
err42.patch.FaceColor = colors(3,:);
err42.patch.FaceAlpha = 0.3;
err42.edge(1).Color = colors(3,:);
err42.edge(2).Color = colors(3,:);

%ylim 
handles.ax.YLim = [0 100];

%add chance line 
chanceVal = 50;
handles.chanceLine = line([min(meanXVals) max(meanXVals)],...
    [chanceVal chanceVal]);
handles.chanceLine.Color = 'k';
handles.chanceLine.LineStyle = '--';
handles.chanceLine.LineWidth = 2;

%beautify
beautifyPlot(handles.fig,handles.ax);

%label axes 
handles.ax.XLabel.String = 'Maze position (cm)';
handles.ax.YLabel.String = 'Accuracy';
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

%set x limit
handles.ax.XLim = [min(meanXVals) max(meanXVals)];

% add legend
handles.leg = legend([err60.mainLine, err51.mainLine, err42.mainLine],...
    {'6-0', '5-1', '4-2'}, 'Location', 'SouthEast');
