function handles = plotSVRGuessVsActual(classOut,handles)
%plotSVRGuessVsActual.m Plots a scatter plot of the
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

if nargin < 2 || isempty(handles)
    handles.fig = figure;
    handles.ax = axes;
end

%turn on hold
hold(handles.ax,'on');

%convert to cm
cmScale = 0.75;
% cmScale = 1;
classOut.guess = classOut.guess*cmScale;
classOut.testClass = classOut.testClass*cmScale;

%get binned means
nBins = 100;
minVal = min(cat(1,classOut.testClass,classOut.guess));
maxVal = max(cat(1,classOut.testClass,classOut.guess));
binVals = linspace(minVal,maxVal,nBins+1);
meanVals = nan(nBins,1);
semVals = nan(nBins,1);
xVals = binVals(1:nBins) + mean(diff(binVals))/2;
for binInd = 1:nBins
    keepInd = classOut.testClass > binVals(binInd) & classOut.testClass <= binVals(binInd+1);
    meanVals(binInd) = mean(classOut.guess(keepInd));
    semVals(binInd) = calcSEM(classOut.guess(keepInd));
end

%add to plot
% errMean = errorbar(xVals,meanVals,semVals);
% errMean.Marker = 'o';
% errMean.LineStyle = 'none';
% errMean.LineWidth = 2;
hold on;
errH = terrorbar(xVals,meanVals,semVals,semVals,0);
scatH = scatter(xVals,meanVals);
scatH.Marker = 'o';



%store
% if isfield(handles,'errMean')
if isfield(handles,'errH')
    %     handles.errMean(length(handles.errMean)+1) = errMean;
    handles.errH{length(handles.errH)+1} = errH;
    handles.scatH(length(handles.scatH)+1) = scatH;
else
    %     handles.errMean = errMean;
    handles.errH = {errH};
    handles.scatH = scatH;
    
    %plot unity line
    handles.unity = plot([minVal maxVal], [minVal maxVal],'k--');
    axis square;
end

%change color
% nColors = length(handles.errMean);
nColors = length(handles.errH);
colors = distinguishable_colors(nColors);
for plotInd = 1:nColors
    %     handles.errMean(plotInd).MarkerEdgeColor = colors(plotInd,:);
    %     handles.errMean(plotInd).MarkerFaceColor = colors(plotInd,:);
    %     handles.errMean(plotInd).Color = colors(plotInd,:);
    
    handles.scatH(plotInd).MarkerEdgeColor = colors(plotInd,:);
    handles.scatH(plotInd).MarkerFaceColor = colors(plotInd,:);
    for i = 1:length(handles.errH{plotInd})
        handles.errH{plotInd}(i).Color = colors(plotInd,:);
    end
end
