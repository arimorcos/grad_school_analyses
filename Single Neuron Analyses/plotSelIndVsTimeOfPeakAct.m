function plotSelIndVsTimeOfPeakAct(imTrials)
%plotSelIndVsTimeOfPeakAct.m Plots the peak selectivity index as a function
%of the time of peak firing 
%
%INPUTS
%imTrials - dataCell containing imaging data
%
%ASM 7/15

cmScale = 0.75;

% get traces
[~,traces] = catBinnedTraces(imTrials);

%get selectivity index 
selInd = getSelectivityIndex(imTrials);

%get mean activity across trials
meanAct = mean(traces,3);

% get index of maximum activity 
[~,maxInd] = max(meanAct,[],2);

%convert to yPosition coordinates
maxYPos = imTrials{1}.imaging.yPosBins(maxInd)*cmScale;

%get peak selectivity index
peakSelInd = max(abs(selInd),[],2);

%% plot 
figH = figure;
axH = axes;

%scatter plot
scatH = scatter(maxYPos,peakSelInd,'filled');
scatH.SizeData = 120;

%beautify
beautifyPlot(figH, axH);

%label
axH.XLabel.String = 'Maze Position at Peak Firing (cm)';
axH.YLabel.String = 'Peak |Selectivity Index|';