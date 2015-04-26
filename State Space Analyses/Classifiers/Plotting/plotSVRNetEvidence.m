function handles = plotSVRNetEvidence(classOut,handles)
%plotSVRGuessVsActual.m Plots a scatter plot of the
%
%INPUTS
%classOut - classifier output
%handles - array of handles
%
%OUTPUTS
%handles
%
%ASM 4/15

if nargin < 2 || isempty(handles)
    handles.fig = figure;
    handles.ax = axes;
end
nSeg = 6;

%turn on hold
hold(handles.ax,'on');

uniqueVals = unique(classOut(1).testClass);
meanVal = nan(1,length(uniqueVals));
semVal = nan(size(meanVal));
for i = 1:length(uniqueVals)
    meanVal(i) = mean(classOut(1).guess(classOut(1).testClass==uniqueVals(i)));
    semVal(i) = calcSEM(classOut(1).guess(classOut(1).testClass==uniqueVals(i)));
end

errMean = errorbar(uniqueVals+0.1*randn(size(uniqueVals)),meanVal,semVal);
% errMean = plot(uniqueVals,meanVal);
errMean.MarkerEdgeColor = 'b';
errMean.MarkerFaceColor = 'b';
errMean.Color = 'b';
errMean.Marker = 'o';
errMean.LineStyle = 'none';
errMean.MarkerSize = 10;
errMean.LineWidth = 2;

switch lower(classOut(1).classMode)
    case 'netev'
        handles.ax.XLabel.String = 'Actual Net Evidence';
        minVal = -nSeg-0.5;
    case 'numleft'
        handles.ax.XLabel.String = 'Actual Num Left';
        minVal = -.5;
    case 'numright'
        minVal = -.5;
        handles.ax.XLabel.String = 'Actual Num Right';
end
maxVal = nSeg+0.5;
if isfield(classOut(1),'viewAngleRange')
    minVal = -0.5;
end
handles.ax.XLim = [minVal maxVal];
handles.ax.YLim = [minVal maxVal];


handles.ax.YLabel.String = 'Mean Guess';

%store
if isfield(handles,'errMean')
    handles.errMean(length(handles.errMean)+1) = errMean;
else
    handles.errMean = errMean;
    
    %plot unity line
    handles.unity = plot([minVal maxVal], [minVal maxVal],'k--');
    axis square;
end

%change color
nColors = length(handles.errMean);
colors = distinguishable_colors(nColors);
for plotInd = 1:nColors
    handles.errMean(plotInd).MarkerEdgeColor = colors(plotInd,:);
    handles.errMean(plotInd).MarkerFaceColor = colors(plotInd,:);
    handles.errMean(plotInd).Color = colors(plotInd,:);
end
