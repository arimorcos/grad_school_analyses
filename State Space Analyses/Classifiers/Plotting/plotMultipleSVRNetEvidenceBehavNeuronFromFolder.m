function handles = plotMultipleSVRNetEvidenceBehavNeuronFromFolder(folder,fileStr)
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
behavClassOut = cell(length(matchFiles),1);
behavNeuronClassOut = cell(length(matchFiles),1);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    behavClassOut{fileInd} = currFileData.behavClassifierOut;
    behavNeuronClassOut{fileInd} = currFileData.behavNeuronClassifierOut;
end

%% net evidence actual vs. guess

%plot
if showErrorBars
    testClassVals = -6:6;
    meanGuessBehav = nan(length(matchFiles),13);
    meanGuessBehavNeuron = nan(length(matchFiles),13);
    for mouseInd = 1:length(matchFiles)
        for class = 1:length(testClassVals)
            matchClassBehav = behavClassOut{mouseInd}(1).testClass == testClassVals(class);
            meanGuessBehav(mouseInd,class) = nanmean(...
                behavClassOut{mouseInd}(1).guess(matchClassBehav));
            matchClassBehavNeuron = behavNeuronClassOut{mouseInd}(1).testClass == testClassVals(class);
            meanGuessBehavNeuron(mouseInd,class) = nanmean(...
                behavNeuronClassOut{mouseInd}(1).guess(matchClassBehavNeuron));
        end
    end
    
    % get mean and sem
    meanAllMiceBehav = nanmean(meanGuessBehav);
    semAllMiceBehav = calcSEM(meanGuessBehav);
    meanAllMiceBehavNeuron = nanmean(meanGuessBehavNeuron);
    semAllMiceBehavNeuron = calcSEM(meanGuessBehavNeuron);
    
    %plot 
    handles.fig = figure;
    handles.ax = axes;
    hold(handles.ax,'on');
    
    
    colors = lines(2);
    
    %errorbar real
    handles.errBehavNeuron = errorbar(testClassVals,meanAllMiceBehavNeuron,semAllMiceBehavNeuron);
    handles.errBehavNeuron.Marker = 'o';
    handles.errBehavNeuron.MarkerFaceColor = handles.errBehavNeuron.MarkerEdgeColor;
    handles.errBehavNeuron.LineStyle = 'none';
    handles.errBehavNeuron.MarkerSize = 3;
    
    %errorbar real
    handles.errBehav = errorbar(testClassVals,meanAllMiceBehav,semAllMiceBehav);
    handles.errBehav.Marker = 'o';
    handles.errBehav.MarkerFaceColor = handles.errBehav.MarkerEdgeColor;
    handles.errBehav.LineStyle = 'none';
    handles.errBehav.MarkerSize = 3;
    
    %beuatify b
    beautifyPlot(handles.fig, handles.ax);
    equalAxes(handles.ax,true);
    
    %labels
    handles.ax.XLabel.String = 'Actual Net Evidence';
    handles.ax.YLabel.String = 'Guessed Net Evidence';
    
    %set lim
    handles.ax.XLim = [-6.2 6.2];
    handles.ax.YLim = [-6.2 6.2];
    
    handles.legend = legend([handles.errBehavNeuron, handles.errBehav],...
        {'Behavioral parameters + neuronal activity',...
         'Behavioral parameters only'},'Location','NorthWest');
else
    handles = [];
    for mouseInd = 1:length(matchFiles)
        handles = plotSVRNetEvidence(behavClassOut{mouseInd},handles,1);
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

%% corr coef difference 
nFiles = length(matchFiles);
behavCorr = nan(nFiles,1);
behavNeurCorr = nan(nFiles,1);
for file = 1:nFiles
    behavCorr(file) = getNetEvCorrCoef(behavClassOut{file});
    behavNeurCorr(file) = getNetEvCorrCoef(behavNeuronClassOut{file});
end

%plot 
figH = figure;
axH = axes; 
hold(axH,'on');

% scatter 
color = lines(1);
for file = 1:nFiles 
    plotH = plot([1 2],[behavCorr(file), behavNeurCorr(file)]);
    plotH.Marker = 'o';
    plotH.MarkerFaceColor = color;
    plotH.Color = color;
    plotH.MarkerEdgeColor = color;
end

%add means 
meanH = scatter([1 2],[mean(behavCorr), mean(behavNeurCorr)]);
meanH.Marker = '+';
meanH.MarkerEdgeColor = 'k';
meanH.SizeData = 300;

%get pVal 
[~,pVal] = ttest2(behavCorr,behavNeurCorr);
fprintf('p = %.3e \n',pVal);

%add to plot
textH = text(0.6, axH.YLim(2) - 0.05*range(axH.YLim),...
    sprintf('p = %.3e',pVal));
textH.VerticalAlignment = 'top';
textH.HorizontalAlignment = 'left';
textH.FontSize = 20;

beautifyPlot(figH,axH);

axH.XTick = [1 2];
axH.XLim = [0.5 2.5];
axH.XTickLabel = {'Behavioral parameters only','Behav + neur'};
axH.XTickLabelRotation = -45;

axH.YLabel.String = 'Net Ev Corr Coef';