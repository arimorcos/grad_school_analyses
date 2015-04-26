function handles = plotAsZScoreShuffle(trace,shuffleTrace,xVals,handles)
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

if nargin < 4 || isempty(handles)
    handles.fig = figure;
    handles.ax = axes;    
end

%convert to row vector 
if iscolumn(trace)
    trace = trace';
end

%calculate std of each column of shuffle and median 
shuffleMedian = median(shuffleTrace);
shuffleSTD = std(shuffleTrace);

%zScore 
zTrace = (trace-shuffleMedian)./shuffleSTD;

%turn on hold
hold(handles.ax,'on');

%convert to cm
cmScale = 0.75;
xVals = xVals*0.75;

%plot zTrace 
plotH = plot(xVals,zTrace);
if isfield(handles,'plot')
    handles.plot(length(handles.plot)+1) = plotH;
else
    handles.plot = plotH;
    handles.chanceLine = line([-1e3 1e3],[2 2]);
    handles.chanceLine.Color = 'k';
    handles.chanceLine.LineStyle = '--';
    handles.ax.XLim = [min(xVals) max(xVals)];
end

%change color 
nColors = length(handles.plot);
colors = distinguishable_colors(nColors);
for plotInd = 1:nColors
    handles.plot(plotInd).Color = colors(plotInd,:);
end
