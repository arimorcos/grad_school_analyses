function handles = plotClusterActivityIndNeuronSortedByLeft(out, neuronInd, figH, axH)
%plotClusterActivityIndNeuronSortedByLeft.m Plots the clustered activity
%sorted by the left turn probability for an individual neuron. Operates on
%output of indNeuronClusterRegress
%
%INPUTS
%out - output of indNeuronClusterRegression
%neuronInd - neuron to plot
%figH - figure handles
%axH - axes handle
%
%OUTPUTS
%handles - structure of handles
%
%ASM 7/15

barVer = true;

if nargin < 3 || isempty(figH)
    handles.fig = figure;
else
    handles.fig = figH;
end
if nargin < 4 || isempty(axH)
    handles.ax = axes;
else
    handles.ax = axH;
end

%filter for neuron
meanAct = out.clusterMeanActivity{neuronInd};
pLeft = out.clusterPLeft{neuronInd};
nPoints = out.clusterNPoints{neuronInd};

meanAct = out.clusterMeanTurn{neuronInd};
pLeft = out.clusterPLeftTurn{neuronInd};
nPoints = out.clusterNPointsTurnClustering{neuronInd};

%remove nans
nanInd = isnan(meanAct);
meanAct = meanAct(~nanInd);
nPoints = nPoints(~nanInd);
pLeft = pLeft(~nanInd);

%remove values less than thresh
thresh = 10;
keepInd = nPoints > thresh;
meanAct = meanAct(keepInd);
pLeft = pLeft(keepInd);

%get sort order
[sortedPLeft,sortOrder] = sort(pLeft);

%apply to meanAct
sortedAct = meanAct(sortOrder);

%add jitter
sortedPLeftJitter = sortedPLeft + 0.05*randn(size(sortedPLeft));

%plot
if barVer
    %take average
    leftAv = mean(sortedAct(sortedPLeft >= 0.5));
    leftSEM = calcSEM(sortedAct(sortedPLeft >= 0.5));
    rightAv = mean(sortedAct(sortedPLeft < 0.5));
    rightSEM = calcSEM(sortedAct(sortedPLeft < 0.5));
    handles.bar = barwitherr([leftSEM; rightSEM],[leftAv;rightAv]);
else
    hold(handles.ax, 'on');
    handles.plot = scatter(sortedPLeftJitter, sortedAct, 'filled');
    handles.line = plot(sortedPLeftJitter,sortedAct);
    handles.line.Color = handles.plot.CData;
    handles.plot.SizeData = 5*nPoints(keepInd);
    handles.plot.MarkerEdgeColor = 'k';
end
% handles.plot = plot(sortedAct);
% handles.plot.Marker = 'o';
% handles.plot.MarkerFaceColor = handles.plot.Color;
% handles.plot.LineStyle = 'none';

%label

handles.ax.YLabel.String = 'Mean \DeltaF/F';
if barVer
    handles.ax.XTickLabel = {'< 0.5','> 0.5'};
    handles.ax.XLabel.String = 'P(Left Turn)';
else
    handles.ax.XLabel.String = 'Cluster p(Left Turn)';
    handles.ax.XTick = 0:0.2:1;
    handles.ax.XLim = [-0.1 1.1];
end
axis(handles.ax, 'square');

