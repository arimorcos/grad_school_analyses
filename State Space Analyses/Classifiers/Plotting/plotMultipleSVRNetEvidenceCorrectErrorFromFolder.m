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
num_left = [];

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
testClassVals = -6:6;
meanGuessCorrect = nan(length(matchFiles),13);
meanGuessError = nan(length(matchFiles),13);
for mouseInd = 1:length(matchFiles)
    for class = 1:length(testClassVals)
        matchClass = ...
            allClassOut{mouseInd}(1).testClass == testClassVals(class);
        correct = allClassOut{mouseInd}(1).correct;
        
        matchClassCorrect = matchClass & correct;
        matchClassError = matchClass & ~correct;
        if ~isempty(test_seg)
            seg_match = allClassOut{mouseInd}(1).segNum == test_seg;
            matchClassCorrect = matchClassCorrect & seg_match;
            matchClassError = matchClassError & seg_match;
        end
        if ~isempty(num_left)
            
        end
        meanGuessCorrect(mouseInd,class) = nanmean(...
            allClassOut{mouseInd}(1).guess(matchClassCorrect));
        meanGuessError(mouseInd,class) = nanmean(...
            allClassOut{mouseInd}(1).guess(matchClassError));
    end
end

meanGuessCorrect = 1.5*meanGuessCorrect;
meanGuessError = 1.5*meanGuessError;
% get mean and sem
meanAllMiceCorrect = nanmean(meanGuessCorrect);
semAllMiceCorrect = calcSEM(meanGuessCorrect);
meanAllMiceError = nanmean(meanGuessError);
semAllMiceError = calcSEM(meanGuessError);

%plot
handles.fig = figure;
handles.ax = axes;
hold(handles.ax, 'on');

%errorbar
handles.errCorrect = errorbar(testClassVals,meanAllMiceCorrect,semAllMiceCorrect);
handles.errCorrect.Marker = 'o';
handles.errCorrect.MarkerFaceColor = handles.errCorrect.MarkerEdgeColor;
handles.errCorrect.LineStyle = 'none';
handles.errCorrect.MarkerSize = 3;

handles.errError = errorbar(testClassVals,meanAllMiceError,semAllMiceError);
handles.errError.Marker = 'o';
handles.errError.MarkerFaceColor = handles.errError.MarkerEdgeColor;
handles.errError.LineStyle = 'none';
handles.errError.MarkerSize = 3;

%beuatify b
beautifyPlot(handles.fig, handles.ax);
equalAxes(handles.ax,true);

%labels
handles.ax.XLabel.String = 'Actual Net Evidence';
handles.ax.YLabel.String = 'Guessed Net Evidence';

%set lim
handles.ax.XLim = [-6.2 6.2];
handles.ax.YLim = [-6.2 6.2];

%label axes
handles.ax.XLabel.FontSize = 30;
handles.ax.YLabel.FontSize = 30;
handles.ax.FontSize = 20;

%maximize
handles.fig.Units = 'normalized';
handles.fig.OuterPosition = [0 0 1 1];

%change labels
currTick = handles.ax.XTickLabel;
newTick = currTick;
for tick = 1:length(newTick)
    if str2double(newTick{tick}) > 0
        newTick{tick} = sprintf('%dL',str2double(newTick{tick}));
    elseif str2double(newTick{tick}) < 0
        newTick{tick} = sprintf('%dR',-1*str2double(newTick{tick}));
    end
end
handles.ax.XTickLabel = newTick;
handles.ax.YTickLabel = newTick;

%set axis to square
axis(handles.ax,'square');

handles.leg = legend({'Correct trials', 'Error trials'}, ...
    'location', 'SouthEast');