function handles = plotDeltaPLeftVsEpoch(deltaPLeft, handles)
%plotDeltaPLeftVsEpoch.m Plots the change in p(left) as a function of maze
%epoch transition
%
%INPUTS
%deltaPLeft.m Output of calcPLeftChange
%
%ASM 6/15

pointLabels = {'Segment 1','Segment 2','Segment 3','Segment 4',...
    'Segment 5','Segment 6','Early Delay','Late Delay','Turn'};

%create figure and axis
if nargin < 2 || isempty(handles)
    handles.fig = figure;
    handles.ax = axes;
end

%turn on hold
hold(handles.ax,'on');

%get mean and sem
transMean = nanmean(abs(deltaPLeft));
transSEM = calcSEM(abs(deltaPLeft));

%plot
errH = errorbar(1:size(deltaPLeft,2),transMean,transSEM);
errH.Marker = 'o';

%beautify
beautifyPlot(handles.fig,handles.ax);

%label
handles.ax.XTickLabel = pointLabels;
handles.ax.XTickLabelRotation = -45;
handles.ax.XTick = 1:size(deltaPLeft,2);
handles.ax.YLabel.String = '\Delta P(Left Turn)';

%store
if isfield(handles,'errH')
    handles.errH(length(handles.errH)+1) = errH;
else
    handles.errH = errH;
end

%change color
nColors = length(handles.errH);
colors = distinguishable_colors(nColors);
for plotInd = 1:nColors
    handles.errH(plotInd).MarkerEdgeColor = colors(plotInd,:);
    handles.errH(plotInd).MarkerFaceColor = colors(plotInd,:);
    handles.errH(plotInd).Color = colors(plotInd,:);
end
