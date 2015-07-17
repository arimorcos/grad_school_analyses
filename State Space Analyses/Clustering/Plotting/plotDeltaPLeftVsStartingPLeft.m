function handles = plotDeltaPLeftVsStartingPLeft(deltaPLeft, startPLeft, mazePatterns, offset, handles)
%plotDeltaPLeftVsStartingPLeft.m Plots the change in p(left) as a function of maze
%epoch transition
%
%INPUTS
%deltaPLeft - Output of calcPLeftChange
%startPLeft - output of calcPLeftChange
%mazePatterns - mazePattern
%
%ASM 6/15

pointLabels = {'Segment 1','Segment 2','Segment 3','Segment 4',...
    'Segment 5','Segment 6','Early Delay','Late Delay','Turn'};

%create figure and axis
if nargin < 5 || isempty(handles)
    handles.fig = figure;
%     handles.ax = axes;
end

if nargin < 4 || isempty(offset)
    offset = 0;
end

%turn on hold
% hold(handles.ax,'on');

% deltaPLeft = abs(deltaPLeft);

%get nTransitions 
nTransitions = size(deltaPLeft,2);

%initialize
scatH = gobjects(nTransitions,2);

for transition = 1:nTransitions 
    
    %create axis 
    handles.ax(transition) = subplot(3,3,transition);
    hold(handles.ax(transition),'on');
    
    %plot 
    markerSize = 20;
    if transition <= size(mazePatterns,2) && transition > offset
        leftSeg = mazePatterns(:,transition - offset) == 1;
        scatH(transition,1) = scatter(startPLeft(leftSeg,transition),deltaPLeft(leftSeg,transition),...
            markerSize,'b');    
        scatH(transition,2) = scatter(startPLeft(~leftSeg,transition),deltaPLeft(~leftSeg,transition),...
            markerSize,'r');    
    else
        scatH(transition,1) = scatter(startPLeft(:,transition),deltaPLeft(:,transition),...
            markerSize,'b');    
    end
    
    %beautify
    beautifyPlot(handles.fig,handles.ax(transition));
    
    %add title 
    handles.ax(transition).Title.String = pointLabels{transition};
    
    %xlim 
    if ~isempty(strfind(lower(inputname(2)),'netev'))
        handles.ax(transition).XLim = [min(startPLeft(:,transition))-0.01 max(startPLeft(:,transition))+0.01];
    else
        handles.ax(transition).XLim = [0 1];
    end
end


%label 
if ~isempty(strfind(lower(inputname(2)),'netev'))
    xLab = suplabel('Starting Mean Net Evidence','x');
else
    xLab = suplabel('Starting P(Left Turn)','x');
end
xLab.FontSize = 30;
yLab = suplabel('\Delta P(Left Turn)','y');
yLab.FontSize = 30;

%label
% handles.ax.XTickLabel = pointLabels;
% handles.ax.XTickLabelRotation = -45;
% handles.ax.XTick = 1:size(deltaPLeft,2);
% handles.ax.YLabel.String = '\Delta P(Left Turn)';

% %store
% if isfield(handles,'errH')
%     handles.errH(length(handles.errH)+1) = errH;
% else
%     handles.errH = errH;
% end
% 
% %change color
% nColors = length(handles.errH);
% colors = distinguishable_colors(nColors);
% for plotInd = 1:nColors
%     handles.errH(plotInd).MarkerEdgeColor = colors(plotInd,:);
%     handles.errH(plotInd).MarkerFaceColor = colors(plotInd,:);
%     handles.errH(plotInd).Color = colors(plotInd,:);
% end
