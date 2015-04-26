function handles = plotWithDashedShuffle(trace,shuffleTrace,xVals,handles,confInt)
%plotAsZScoreShuffle.m Plots a trace as number of standard deviations above
%the shuffle mean 
%
%INPUTS
%trace - nXVals x 1 array of values 
%shuffleTraces - nShuffles x nXVals array of shuffled values 
%xVals - x values to plot 
%handles - array of handles
%
%OUTPUTS
%handles
%
%ASM 4/15

if nargin < 5 || isempty(confInt)
    confInt = 95;
end
if nargin < 4 || isempty(handles)
    handles.fig = figure;
    handles.ax = axes;    
end

%turn on hold
hold(handles.ax,'on');

%get confidence intervals
highInd = (100-confInt)/2;
lowInd = 100 - highInd;
confVals = prctile(shuffleTrace,[lowInd, highInd]);
if isrow(confVals)
    confVals = confVals';
end

%convert xVals
cmScale = 0.75;
xVals = xVals*cmScale;

%plot trace 
plotH = plot(xVals,trace);
plotH.LineWidth = 2;

%plot shuffles 
shuffleLow = plot(xVals,confVals(2,:));
shuffleHigh = plot(xVals,confVals(1,:));
shuffleLow.LineStyle = '--';
shuffleHigh.LineStyle = '--';

%store 
if isfield(handles,'plot')
    handles.plot(length(handles.plot)+1) = plotH;
    handles.shuffleLow(length(handles.shuffleLow)+1) = shuffleLow;
    handles.shuffleHigh(length(handles.shuffleHigh)+1) = shuffleHigh;
else
    handles.plot = plotH;
    handles.shuffleLow = shuffleLow;
    handles.shuffleHigh = shuffleHigh;
%     handles.chanceLine = line([-1e3 1e3],[50 50]);
%     handles.chanceLine.Color = 'k';
%     handles.chanceLine.LineStyle = '--';
    if length(xVals) == 1
%         handles.ax.XLim = [xVals - 0.5 xVals + 0.5];
    else
        handles.ax.XLim = [min(xVals) max(xVals)];
    end
    handles.ax.YLim = [0 100];
end

%change color 
nColors = length(handles.plot);
colors = distinguishable_colors(nColors);
for plotInd = 1:nColors
    handles.plot(plotInd).Color = colors(plotInd,:);
    handles.shuffleLow(plotInd).Color = colors(plotInd,:);
    handles.shuffleHigh(plotInd).Color = colors(plotInd,:);
end
