function handles = plotMultipleClassifiersFromFolder(folder,fileStr,plotType,title,xLab,yLab)
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

segRanges = 0:80:480;

if nargin < 3 || isempty(plotType)
    plotType = 'zScore';
end
if nargin < 6 || isempty(yLab)
    switch plotType
        case 'zScore'
            yLab = 'Shuffle standard deviations above mean';
        case 'dashBounds'
            yLab = 'Classifier Accuracy';
    end
end
if nargin < 5 || isempty(xLab)
    xLab = 'Y Position (binned)';
end
if nargin < 4 || isempty(title)
    title = '';
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
    currFileData = load(matchFiles{fileInd});
    allAcc{fileInd} = currFileData.accuracy(2:end-1);
    allShuffle{fileInd} = currFileData.shuffleAccuracy(:,2:end-1);
    allxVals{fileInd} = currFileData.yPosBins(2:end-1);
end

%plot 
handles = plotMultipleMiceShuffleAccuracy(allAcc,allShuffle,allxVals,plotType);

%label axes 
handles.ax.XLabel.String = xLab;
handles.ax.YLabel.String = yLab;
handles.ax.FontSize = 20;
handles.ax.XLim = [min(cat(2,allxVals{:})) max(cat(2,allxVals{:}))];
handles.ax.Title.String = title;

%add segment dividers 
handles.lineH = gobjects(length(segRanges),1);
for segInd = 1:length(segRanges)
    handles.lineH(segInd) = line([segRanges(segInd) segRanges(segInd)],handles.ax.YLim);
    handles.lineH(segInd).Color = 'g';
    handles.lineH(segInd).LineStyle = '--';
end