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

showLegend = false;
showErrorBars = true;

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
if showErrorBars
    testClassVals = -6:6;
    meanGuess = nan(length(matchFiles),13);
    for mouseInd = 1:length(matchFiles)
        for class = 1:length(testClassVals)
            matchClass = allClassOut{mouseInd}(1).testClass == testClassVals(class);
            meanGuess(mouseInd,class) = nanmean(...
                allClassOut{mouseInd}(1).guess(matchClass));
        end
    end
    
    % get mean and sem
    meanAllMice = mean(meanGuess);
    semAllMice = calcSEM(meanGuess);
    
    %plot 
    handles.fig = figure;
    handles.ax = axes;
    
    %errorbar 
    handles.err = errorbar(testClassVals,meanAllMice,semAllMice);
    handles.err.Marker = 'o';
    handles.err.MarkerFaceColor = handles.err.MarkerEdgeColor;
    handles.err.LineStyle = 'none';
    handles.err.MarkerSize = 3;
    
    %beuatify b
    beautifyPlot(handles.fig, handles.ax);
    equalAxes(handles.ax,true);
    
    %labels
    handles.ax.XLabel.String = 'Actual Net Evidence';
    handles.ax.YLabel.String = 'Guessed Net Evidence';
    
    %set lim
    handles.ax.XLim = [-6.2 6.2];
    handles.ax.YLim = [-6.2 6.2];
else
    handles = [];
    for mouseInd = 1:length(matchFiles)
        handles = plotSVRNetEvidence(allClassOut{mouseInd},handles,1);
    end
end

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

%add legend
if showLegend
    legend(handles.errMean,strrep(matchFiles,'_','\_'),'Location','BestOutside');
end

%% mean squared error
%plot
handles = [];
for mouseInd = 1:length(matchFiles)
    handles = plotSVRNetEvidence(allClassOut{mouseInd},handles,2);
end

%label axes
handles.ax.XLabel.FontSize = 30;
handles.ax.YLabel.FontSize = 30;
handles.ax.FontSize = 20;

%maximize
handles.fig.Units = 'normalized';
handles.fig.OuterPosition = [0 0 1 1];

%set axis to square
axis(handles.ax,'square');

%add legend
if showLegend
    tempHandles = gobjects(length(handles.scatH),1);
    for i = 1:length(handles.scatH)
        tempHandles(i) = handles.scatH{i}(1);
    end
    legend(tempHandles,strrep(matchFiles,'_','\_'),'Location','BestOutside');
end