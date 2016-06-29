function handles = plotMultipleSVRNetEvidenceFromFolder(folder,fileStr)
%plotMultipleSVRNetEvidenceFromFolder.m Plots multiple classifiers based on a
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

test_seg = 6;

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
allClassOut = cell(length(matchFiles),1);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    field = fieldnames(currFileData);
    if length(field) > 1
        allClassOut{fileInd} = currFileData.groupClassifier;
    else
        allClassOut{fileInd} = currFileData.(field{1});
    end
end

%% net evidence actual vs. guess

%plot
meanGuessLeft = nan(length(matchFiles),1);
meanGuessRight = nan(length(matchFiles),1);
semGuessLeft = nan(length(matchFiles),1);
semGuessRight = nan(length(matchFiles),1);
numGuessLeft = nan(length(matchFiles),1);
numGuessRight = nan(length(matchFiles),1);
for mouseInd = 1:length(matchFiles)
        matchClass = ...
            allClassOut{mouseInd}(1).testClass == 0;
        leftTurn = allClassOut{mouseInd}(1).leftTurn;
        
        matchClassLeft = matchClass & leftTurn;
        matchClassRight = matchClass & ~leftTurn;
        
        seg_match = allClassOut{mouseInd}(1).segNum == test_seg;
        matchClassLeft = matchClassLeft & seg_match;
        matchClassRight = matchClassRight & seg_match;
        
        meanGuessLeft(mouseInd) = nanmean(...
            allClassOut{mouseInd}(1).guess(matchClassLeft));
        meanGuessRight(mouseInd) = nanmean(...
            allClassOut{mouseInd}(1).guess(matchClassRight));
        
        semGuessLeft(mouseInd) = calcSEM(...
            allClassOut{mouseInd}(1).guess(matchClassLeft));
        semGuessRight(mouseInd) = calcSEM(...
            allClassOut{mouseInd}(1).guess(matchClassRight));
        
        numGuessLeft(mouseInd) = length(...
            allClassOut{mouseInd}(1).guess(matchClassLeft));
        numGuessRight(mouseInd) = length(...
            allClassOut{mouseInd}(1).guess(matchClassRight));
end

%plot
handles.fig = figure;
handles.ax = axes;
hold(handles.ax, 'on');

%plot 
left_xvals =linspace(0.8, 1.2, length(meanGuessLeft));
handles.errLeft = errorbar(left_xvals,...
    meanGuessLeft,semGuessLeft);
handles.errLeft.Marker = 'o';
handles.errLeft.MarkerFaceColor = handles.errLeft.MarkerEdgeColor;
handles.errLeft.LineStyle = 'none';
handles.errLeft.MarkerSize = 10;

right_xvals = linspace(1.8, 2.2, length(meanGuessRight));
handles.errRight = errorbar(right_xvals,...
    meanGuessRight,semGuessRight);
handles.errRight.Marker = 'o';
handles.errRight.MarkerFaceColor = handles.errRight.MarkerEdgeColor;
handles.errRight.LineStyle = 'none';
handles.errRight.MarkerSize = 10;

for i = 1:length(left_xvals)
    textH = text(left_xvals(i), meanGuessLeft(i) + semGuessLeft(i) + 0.1,...
        sprintf('n = %d', numGuessLeft(i)));
    textH.VerticalAlignment = 'bottom';
    textH.HorizontalAlignment = 'center';
end

for i = 1:length(right_xvals)
    textH = text(right_xvals(i), meanGuessRight(i) + semGuessRight(i) + 0.1,...
        sprintf('n = %d', numGuessRight(i)));
    textH.VerticalAlignment = 'bottom';
    textH.HorizontalAlignment = 'center';
end

beautifyPlot(handles.fig, handles.ax);

handles.ax.XLim = [0 3];
handles.ax.XTick = [1 2];
handles.ax.XTickLabel = {'Left choice', 'Right choice'};
handles.ax.XTickLabelRotation = -45;
handles.ax.YLabel.String = 'Predicted net evidence on 3-3 trials';

