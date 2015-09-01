function handles = plotMultipleBehavRegressionFromFolder(folder,fileStr)
%plotMultipleBehavRegressionFromFolder.m Plots multiple delta seg
%behavioral regression from folder
%
%INPUTS 
%folder - path to folder 
%fileStr - string to match files to 
%
%OUTPUTS
%handles - structure of handles 
%
%ASM 4/15

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array 
out = cell(length(matchFiles),1);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    out{fileInd} = currFileData.out;    
end

%nFiles
nFiles = length(matchFiles);

%% plot nSTD 

%create figure and axes
handles.fig = figure;
handles.axL = subplot(1,2,1);

%hold 
hold(handles.axL,'on');

%generate colors
colors = distinguishable_colors(nFiles);

%get nDelta
nDelta = length(out{fileInd}.adjR2BehavNeurDelta);

% loop through and plot 
handles.plot = gobjects(nFiles,1);
for fileInd = 1:nFiles
    
    %get median and std 
    medianVal = median(out{fileInd}.adjR2BehavNeurDeltaShuffle,2);
    stdVal = std(out{fileInd}.adjR2BehavNeurDeltaShuffle,0,2);
    
    %get nSTD above median 
    nSTDAbove = (out{fileInd}.adjR2BehavNeurDelta - medianVal)./stdVal;
    
    %plot 
    handles.plot(fileInd) = plot(0:(nDelta-1), nSTDAbove);
    handles.plot(fileInd).Color = colors(fileInd,:);
    handles.plot(fileInd).LineWidth = 2;
    
end

%add dashed 2 STD line 
handles.stdLine = line([0 nDelta-1], [2 2]);
handles.stdLine.Color = 'k';
handles.stdLine.LineStyle = '--';
handles.stdLine.LineWidth = 2;

%beautify
beautifyPlot(handles.fig, handles.axL);

%label 
% handles.axL.XLabel.String = '\Delta Maze Epochs';
handles.axL.YLabel.String = '# STD Above Shuffle Median';
handles.axL.XLim = [1 nDelta-1];

%% plot sig diff to behav 

%create axis 
handles.axR = subplot(1,2,2);
hold(handles.axR, 'on');

%create nFiles x nEpoch arrays of each 
behavNeur = cell2mat(cellfun(@(x) x.adjR2BehavNeurDelta', out, 'UniformOutput',false));
behavOnly = cell2mat(cellfun(@(x) x.adjR2BehavDelta', out, 'UniformOutput',false));

% plot behavior only 
handles.behavPlot = errorbar(0:(nDelta-1), mean(behavOnly), calcSEM(behavOnly));
handles.behavPlot.Color = 'r';
handles.behavPlot.MarkerSize = 10;
handles.behavPlot.MarkerFaceColor = 'r';
handles.behavPlot.LineStyle = 'none';
handles.behavPlot.Marker = 'o';

% plot behavior and neur 
handles.behavNeurPlot = errorbar(0:(nDelta-1), mean(behavNeur), calcSEM(behavNeur));
handles.behavNeurPlot.Color = 'b';
handles.behavNeurPlot.MarkerSize = 10;
handles.behavNeurPlot.MarkerFaceColor = 'b';
handles.behavNeurPlot.LineStyle = 'none';
handles.behavNeurPlot.Marker = 'o';

%loop through and add significance 
handles.neurSig = gobjects(nDelta-1, 1);
maxVal = max(cat(1,handles.behavPlot.YData + handles.behavPlot.UData,...
    handles.behavNeurPlot.YData + handles.behavNeurPlot.UData));
textOffset = 0.02*range(handles.axR.YLim);
for delta = 2:nDelta
    
    %get pVal
    [~,pVal] = ttest2(behavOnly(:,delta), behavNeur(:,delta));
    
    %add significance 
    if pVal <= 0.001
        textH = text(delta-1, maxVal(delta)+textOffset, '***');
    elseif pVal <= 0.01
        textH = text(delta-1, maxVal(delta)+textOffset, '**');
    elseif pVal <= 0.05
        textH = text(delta-1, maxVal(delta)+textOffset, '*');
    end
    textH.FontSize = 30;
    textH.HorizontalAlignment = 'center';
    
end

%label
handles.axR.YLabel.String = 'Adjusted R^{2}';
handles.rightLegend = legend([handles.behavPlot, handles.behavNeurPlot],...
    {'Behavior Only', 'Behavior + Neuronal Clusters'},'Location','NorthEast');

%beautify 
beautifyPlot(handles.fig, handles.axR);

%change limits 
handles.axR.XLim = [-0.2 nDelta-0.8];

%% extra labels 
%add xlabel
[~,handles.xLab] = suplabel('\Delta Maze Epochs','x',[0.13 0.2 0.775 0.815]);
handles.xLab.FontSize = 30;
