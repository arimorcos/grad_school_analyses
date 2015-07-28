function handles = plotPLeftChanges(out, xVar, yVar, offset, handles)
%plotPLeftChanges.m Plots the change in variable one as function of var 2 
%
%INPUTS
%out - output of calcPLeftChange 
%xVar - x variable to plot 
%yVar - y variable to plot 
%mazePatterns - patterns of mazes 
%offset - offset of segments 
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
[nTrials, nTransitions] = size(out.deltaPLeft);


%initialize
scatH = gobjects(nTransitions,2);

for transition = 1:nTransitions 
    
    %create axis 
    handles.ax(transition) = subplot(3,3,transition);
    hold(handles.ax(transition),'on');
    
    %plot 
    markerSize = 20;
    xRange = range(out.(xVar)(:,transition)); %get x and y range
    yRange = range(out.(yVar)(:,transition));
    yRange = max(1, yRange);
    xRange = max(1, xRange);
    xJitter = 0.05*xRange*rand(nTrials,1).*randi([-1 1],nTrials,1);
    yJitter = 0.05*yRange*rand(nTrials,1).*randi([-1 1],nTrials,1);
    if transition <= size(out.mazePatterns,2) && transition > offset
        leftSeg = out.mazePatterns(:,transition - offset) == 1;
        scatH(transition,1) = scatter(out.(xVar)(leftSeg,transition) + xJitter(1:sum(leftSeg)),...
            out.(yVar)(leftSeg,transition) + yJitter(1:sum(leftSeg)),...
            markerSize,'b');    
        scatH(transition,2) = scatter(out.(xVar)(~leftSeg,transition) + xJitter(1:sum(~leftSeg)),...
            out.(yVar)(~leftSeg,transition) + yJitter(1:sum(~leftSeg)),...
            markerSize,'r');    
    else
        scatH(transition,1) = scatter(out.(xVar)(:,transition) + xJitter,...
            out.(yVar)(:,transition) + yJitter,...
            markerSize,'k');    
    end
    
    %add legend 
    if transition == 1 + offset
        legend([scatH(1+offset,1), scatH(1+offset,2)],'L','R','Location','Best');
    end
    
    %beautify
    beautifyPlot(handles.fig,handles.ax(transition));
    
    %add title 
    handles.ax(transition).Title.String = pointLabels{transition};
    
    %xlim 
    if ~isempty(strfind(lower(xVar),'netev'))
        minVal = min(out.(xVar)(:,transition)) - 0.01 + min(yJitter);
        maxVal = max(out.(xVar)(:,transition)) + 0.01 + max(yJitter);
        handles.ax(transition).XLim = [-1*max(abs(minVal),maxVal), max(abs(minVal),maxVal)];
    else
        handles.ax(transition).XLim = [0 + min(xJitter), 1 + max(xJitter)];
%         handles.ax(transition).YLim = [-1 1];
    end
    
    %ylim 
    if ~isempty(strfind(lower(yVar),'netev'))
        minVal = min(out.(yVar)(:,transition)) - 0.01 + min(yJitter);
        maxVal = max(out.(yVar)(:,transition)) + 0.01 + max(yJitter);
        handles.ax(transition).YLim = [-1*max(abs(minVal),maxVal), max(abs(minVal),maxVal)];
    elseif ~isempty(strfind(lower(yVar),'deltapleft'))
        handles.ax(transition).YLim = [-1 + min(yJitter), 1 + max(yJitter)];
    elseif ~isempty(strfind(lower(yVar),'switchprob'))
        handles.ax(transition).YLim = [0 + min(yJitter), 1 + max(yJitter)];
    end
    
    
end

%scale 
scale_subplots(1.08,handles.ax);

%label 
if ~isempty(strfind(lower(xVar),'netev'))
    xLab = suplabel('Starting Mean Net Evidence','x');
elseif ~isempty(strfind(lower(xVar),'deltapleft'))
    xLab = suplabel('\Delta P(Left Turn)','x');
else
    xLab = suplabel('Starting P(Left Turn)','x');
end
xLab.FontSize = 30;
if ~isempty(strfind(lower(yVar),'netev'))
    yLab = suplabel('\Delta Net Evidence','y');
elseif ~isempty(strfind(lower(yVar),'deltapleft'))
    yLab = suplabel('\Delta P(Left Turn)','y');
elseif ~isempty(strfind(lower(yVar),'switchprob'))
    yLab = suplabel('Switch Trial','y');
end
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
