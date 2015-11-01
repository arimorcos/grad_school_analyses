function handles = plotMultipleSVRNetEvidenceSwapFromFolder(folder,fileStr)
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
realClassOut = cell(length(matchFiles),1);
swapClassOut = cell(length(matchFiles),1);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    realClassOut{fileInd} = currFileData.realClassifierOut;
    swapClassOut{fileInd} = currFileData.swapClassifierOut;
end

%% net evidence actual vs. guess

%plot
if showErrorBars
    testClassVals = -6:6;
    meanGuessReal = nan(length(matchFiles),13);
    meanGuessSwap = nan(length(matchFiles),13);
    for mouseInd = 1:length(matchFiles)
        for class = 1:length(testClassVals)
            matchClass = realClassOut{mouseInd}(1).testClass == testClassVals(class);
            meanGuessReal(mouseInd,class) = nanmean(...
                realClassOut{mouseInd}(1).guess(matchClass));
            meanGuessSwap(mouseInd,class) = nanmean(...
                swapClassOut{mouseInd}(1).guess(matchClass));
        end
    end
    
    % get mean and sem
    meanAllMiceReal = 2*nanmean(meanGuessReal);
    semAllMiceReal = calcSEM(meanGuessReal);
    meanAllMiceSwap = 2*nanmean(meanGuessSwap);
    semAllMiceSwap = calcSEM(meanGuessSwap);
    
    %plot 
    handles.fig = figure;
    handles.ax = axes;
    hold(handles.ax,'on');
    
    
    colors = lines(2);
    
    %errorbar real
    handles.errReal = errorbar(testClassVals,meanAllMiceReal,semAllMiceReal);
    handles.errReal.Marker = 'o';
    handles.errReal.MarkerFaceColor = handles.errReal.MarkerEdgeColor;
    handles.errReal.LineStyle = 'none';
    handles.errReal.MarkerSize = 3;
    
    %errorbar real
    handles.errSwap = errorbar(testClassVals,meanAllMiceSwap,semAllMiceSwap);
    handles.errSwap.Marker = 'o';
    handles.errSwap.MarkerFaceColor = handles.errSwap.MarkerEdgeColor;
    handles.errSwap.LineStyle = 'none';
    handles.errSwap.MarkerSize = 3;
    
    %beuatify b
    beautifyPlot(handles.fig, handles.ax);
    equalAxes(handles.ax,true);
    
    %labels
    handles.ax.XLabel.String = 'Actual Net Evidence';
    handles.ax.YLabel.String = 'Guessed Net Evidence';
    
    %set lim
    handles.ax.XLim = [-6.2 6.2];
    handles.ax.YLim = [-6.2 6.2];
    
    handles.legend = legend([handles.errReal, handles.errSwap],...
        {'Original','Swapped view angles'},'Location','NorthWest');
else
    handles = [];
    for mouseInd = 1:length(matchFiles)
        handles = plotSVRNetEvidence(realClassOut{mouseInd},handles,1);
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
    handles = plotSVRNetEvidence(realClassOut{mouseInd},handles,2);
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