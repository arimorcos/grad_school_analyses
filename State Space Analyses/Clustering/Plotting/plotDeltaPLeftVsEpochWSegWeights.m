function handles = plotDeltaPLeftVsEpochWSegWeights(deltaPLeft,dataCell,handles)
%plotDeltaPLeftVsEpoch.m Plots the change in p(left) as a function of maze
%epoch transition 
%
%INPUTS
%deltaPLeft.m Output of calcPLeftChange 
%
%ASM 6/15

%create figure and axis
if nargin < 3 || isempty(handles)
    handles.fig = figure;
    handles.ax1 = axes;
    makeAx2 = true;
else
    makeAx2 = false;
end

%turn on hold
hold(handles.ax1,'on');

pointLabels = {'Segment 1','Segment 2','Segment 3','Segment 4',...
    'Segment 5','Segment 6','Early Delay','Late Delay','Turn'};

%get segWeights 
if length(dataCell) > 2
	[segWeights, confInt] = getSegWeights(dataCell);
else
    segWeights = dataCell{1};
    confInt = dataCell{2};
end
confInt = abs(bsxfun(@minus,segWeights,confInt));

%beautify 
beautifyPlot(handles.fig,handles.ax1);

%crop deltaPleft  to segments 
deltaPLeft = deltaPLeft(:,1:length(segWeights));

%get mean and sem 
transMean = nanmean(abs(deltaPLeft));
transSEM = calcSEM(abs(deltaPLeft));

%plot p(left)
errH1 = errorbar(1:size(deltaPLeft,2),transMean,transSEM);
errH1.Marker = 'o';

%plot regWeights 
if makeAx2
    handles.ax2 = axes('Position',handles.ax1.Position);
    hold(handles.ax2,'on');
end
errH2 = errorbar(1:size(deltaPLeft,2),segWeights,confInt(:,1),confInt(:,2),'Parent',handles.ax2);
errH2.Marker = '^';
handles.ax2.XTick = [];
handles.ax2.YAxisLocation = 'right';
handles.ax2.Color = 'none';

axis(handles.ax1,'square');
axis(handles.ax2,'square');
handles.ax1.YColor = 'b';
handles.ax2.YColor = 'r';

%label 
handles.ax2.LabelFontSizeMultiplier = 1.5;
handles.ax1.XTick = 1:length(segWeights);
handles.ax1.XTickLabel = pointLabels;
handles.ax1.XTickLabelRotation = -45;
handles.ax1.YLabel.String = '\Delta P(Left Turn)';
handles.ax2.YLabel.String = '\beta';
% handles.ax1.XLim = [0.5 length(segWeights) + 0.5];
% handles.ax2.XLim = handles.ax1.XLim;

%store
if isfield(handles,'errH1')
    handles.errH1(length(handles.errH1)+1) = errH1;
    handles.errH2(length(handles.errH2)+1) = errH2;
else
    handles.errH1 = errH1;
    handles.errH2 = errH2;
end

%change color
nColors = length(handles.errH1);
colors = distinguishable_colors(nColors);
for plotInd = 1:nColors
    handles.errH1(plotInd).MarkerEdgeColor = colors(plotInd,:);
    handles.errH1(plotInd).MarkerFaceColor = colors(plotInd,:);
    handles.errH1(plotInd).Color = colors(plotInd,:);
    handles.errH2(plotInd).MarkerEdgeColor = colors(plotInd,:);
    handles.errH2(plotInd).MarkerFaceColor = colors(plotInd,:);
    handles.errH2(plotInd).Color = colors(plotInd,:);
end
