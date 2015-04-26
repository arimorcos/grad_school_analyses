function handles = plotMultipleSVRFromFolder(folder,fileStr,labApp)
%plotMultipleClassifiersFromFolder.m Plots multiple classifiers based on a
%specific folder path 
%
%INPUTS 
%folder - path to folder 
%fileStr - string to match files to 
%labApp - portion to append to guess/actual
%
%OUTPUTS
%handles - structure of handles 
%
%ASM 4/15

cmScale = 0.75;

if nargin < 3 || isempty(labApp)
    labApp = '';
end

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array 
allClassOut = cell(length(matchFiles),1);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    field = fieldnames(currFileData);
    if length(field) > 1 
        allClassOut{fileInd} = currFileData.sinBinRunSpeed;
    else
        allClassOut{fileInd} = currFileData.(field{1});
    end
    
end

%plot 
handles = [];
for mouseInd = 1:length(matchFiles)
    handles = plotSVRGuessVsActual(allClassOut{mouseInd},handles);
end

%label axes 
handles.ax.XLabel.String = sprintf('Actual %s',labApp);
handles.ax.YLabel.String = sprintf('Guessed %s',labApp);
handles.ax.XLabel.FontSize = 30;
handles.ax.YLabel.FontSize = 30;
handles.ax.FontSize = 20;

%set x limit
allVals = arrayfun(@(x) cat(2,handles.errMean(x).XData(~isnan(handles.errMean(x).YData)),...
    handles.errMean(x).YData(~isnan(handles.errMean(x).YData))),...
    1:length(handles.errMean),'UniformOutput',false);
allVals = cat(2,allVals{:});
minVal = min(allVals);
maxVal = max(allVals);
handles.ax.XLim = [minVal - 0.02*range(allVals) maxVal + 0.02*range(allVals)];
handles.ax.YLim = [minVal - 0.02*range(allVals) maxVal + 0.02*range(allVals)];

%set axis to square
axis(handles.ax,'square');

%maximize 
handles.fig.Units = 'normalized';
handles.fig.OuterPosition = [0 0 1 1];