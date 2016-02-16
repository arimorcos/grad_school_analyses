function handles = plotMultipleCorrectErrorSVM(folder,fileStr)
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
allCorrect = cell(length(matchFiles),1);
allError = cell(length(matchFiles),1);
allxVals = cell(length(matchFiles),1);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    allCorrect{fileInd} = currFileData.accuracy_correct(2:end-2);
    allError{fileInd} = currFileData.accuracy_error(2:end-2);
    allxVals{fileInd} = currFileData.yPosBins(2:end-2);
end

%cat accuracy 
minBins = min(cellfun(@length, allCorrect));
maxBins = max(cellfun(@length, allCorrect));
cropAccCorrect = cellfun(@(x) x(end-minBins+1:end),allCorrect,'UniformOutput',false);
cropAccError = cellfun(@(x) x(end-minBins+1:end),allError,'UniformOutput',false);
cropXVals = cellfun(@(x) x(end-minBins+1:end),allxVals,'UniformOutput',false);
catAccCorrect =cat(2,cropAccCorrect{:})';
catAccError =cat(2,cropAccError{:})';
catXVals = cat(1,cropXVals{:});
meanXVals = mean(catXVals);
cmScale = 0.75;
meanXVals = meanXVals*cmScale;

% get mean and sem
meanAccCorrect = mean(catAccCorrect);
semAccCorrect = calcSEM(catAccCorrect);
meanAccError = mean(catAccError);
semAccError = calcSEM(catAccError);

%dsamp
meanXVals = meanXVals(1:dsamp:end);
meanAccCorrect = meanAccCorrect(1:dsamp:end);
semAccCorrect = semAccCorrect(1:dsamp:end);
meanAccError = meanAccError(1:dsamp:end);
semAccError = semAccError(1:dsamp:end);

%create figure 
handles.fig = figure;
handles.ax = axes;

hold(handles.ax, 'on');

colors = lines(3);

%plot correct
errCorrect = shadedErrorBar(meanXVals, meanAccCorrect ,semAccCorrect);
errCorrect.mainLine.Color = colors(1,:);
errCorrect.patch.FaceColor = colors(1,:);
errCorrect.patch.FaceAlpha = 0.3;
errCorrect.edge(1).Color = colors(1,:);
errCorrect.edge(2).Color = colors(1,:);

%plot error
errError = shadedErrorBar(meanXVals, meanAccError ,semAccError);
errError.mainLine.Color = colors(2,:);
errError.patch.FaceColor = colors(2,:);
errError.patch.FaceAlpha = 0.3;
errError.edge(1).Color = colors(2,:);
errError.edge(2).Color = colors(2,:);

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
handles.leg = legend([errCorrect.mainLine, errError.mainLine],...
    {'Correct trials', 'Error trials'}, 'Location', 'SouthEast');
