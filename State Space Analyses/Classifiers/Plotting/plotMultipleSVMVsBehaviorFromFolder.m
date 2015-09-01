function handles = plotMultipleSVMVsBehaviorFromFolder(folder,fileStr)
%plotMultipleSVMVsBehaviorFromFolder.m Plots multiple classifiers based on a
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

segRanges = 0:80:480;

%get list of files in folder
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));
if isempty(matchFiles)
    warning('No files match');
    return;
end

%loop through each file and create array
nFiles = length(matchFiles);
allYPosBins = cell(nFiles,1);
allBehavAcc = cell(nFiles,1);
% allShuffleAcc = cell(nFiles,1);
allAcc = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    allYPosBins{fileInd} = currFileData.yPosBins;
    allBehavAcc{fileInd} = currFileData.behavAccuracy;
%     allShuffleAcc{fileInd} = currFileData.shuffleAccuracy;
    allAcc{fileInd} = currFileData.accuracy;
end

%% calculate 
%get min length and crop 
minLength = min(cellfun(@length,allYPosBins));
allYPosBins = cellfun(@(x) x(2:minLength),allYPosBins,'uniformoutput',false);
allBehavAcc = cellfun(@(x) x(2:minLength),allBehavAcc,'uniformoutput',false);
allAcc = cellfun(@(x) x(2:minLength),allAcc,'uniformoutput',false);
% allShuffleAcc = cellfun(@(x) x(:,2:minLength),allShuffleAcc,'uniformoutput',false);

%get nShuffles 
% nShuffles = size(allShuffleAcc{1},1);

diffAccReal = nan(nFiles,minLength-1);
% diffAccShuffle = nan(nShuffles*nFiles,minLength-1);
for fileInd = 1:nFiles
    %take difference 
    diffAccReal(fileInd,:) = allAcc{fileInd} - allBehavAcc{fileInd};
    
    %take shuffle difference 
%     diffAccShuffle(1+nShuffles*(fileInd-1):nShuffles*fileInd,:) = ...
%         bsxfun(@minus,allShuffleAcc{fileInd},allBehavAcc{fileInd}');
    
end

%take mean and sem 
meanDiffAccReal = mean(diffAccReal);
semDiffAccReal = calcSEM(diffAccReal);
meanXVals = mean(cat(1,allYPosBins{:}));

%% plot 
handles.fig = figure;
handles.ax = axes;

cmScale = 0.75;
meanXVals=  meanXVals*cmScale;

errH = shadedErrorBar(meanXVals,meanDiffAccReal,semDiffAccReal);
color = [0    0.4470    0.7410];
errH.mainLine.Color = color;
errH.patch.FaceColor = color;
errH.patch.FaceAlpha = 0.3;
errH.edge(1).Color = color;
errH.edge(2).Color = color;

%ylim 
% handles.ax.YLim = [0 100];

%add chance line 
% chanceVal = mean(catShuffle(:));
chanceVal = 0;
handles.chanceLine = line([min(meanXVals) max(meanXVals)],...
    [chanceVal chanceVal]);
handles.chanceLine.Color = 'k';
handles.chanceLine.LineStyle = '--';
handles.chanceLine.LineWidth = 2;

%beautify
beautifyPlot(handles.fig,handles.ax);

%label axes 
handles.ax.XLabel.String = 'Maze position (cm)';
handles.ax.YLabel.String = 'NeurAcc - behavAcc';
handles.ax.FontSize = 20;

%add segment dividers 
segRanges = segRanges*cmScale;
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

%set x limit
handles.ax.XLim = [min(meanXVals) max(meanXVals)];

%maximize 
handles.fig.Units = 'normalized';
handles.fig.OuterPosition = [0 0 1 1];
