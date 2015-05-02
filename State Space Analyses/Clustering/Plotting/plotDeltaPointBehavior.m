function plotDeltaPointBehavior(varargin)
%plotDeltaPointBehavior.m Plots whether the distributions are significantly
%different at each delta point 
%
%INPUTS
%deltaPointNeurons - deltaPoint structure with bootstrapping created by
%   quanitfyInternalVariability for neurons
%deltaPointNeurons - deltaPoint structure with bootstrapping created by
%   quanitfyInternalVariability for behavior 
%
%OR 
%
%dataCell - dataCell from which to generate data
%
%ASM 4/15

%% process inputs
if length(varargin) == 3 
    deltaPointNeuron = varargin{1};
    deltaPointBehavior = varargin{2};
    deltaPointBehavNeur = varargin{3};
elseif length(varargin) == 1 && iscell(varargin{1})
    [~,~,deltaPointNeuron] = quantifyInternalVariability(dataCell,...
        'usebootstrapping',true);
    [~,~,deltaPointBehavior] = quantifyInternalVariability(dataCell,...
        'usebootstrapping',true,'useBehavior',true);
    [~,~,deltaPointBehavNeur] = quantifyBehavToNeuronalClusterProb(dataCell,...
        'usebootstrapping',true);
else
    error('Cannot interpret inputs');
end

%% calculate statistics

%get nDelta 
nDelta = size(deltaPointNeuron.nSTDAboveMedian,1);

%loop through 
pVal = nan(nDelta,3);
for delta = 1:nDelta
    [~,pVal(delta,1)] = ttest2(deltaPointNeuron.allNSTDAboveMedian(delta,:),...
        deltaPointBehavior.allNSTDAboveMedian(delta,:));
    [~,pVal(delta,2)] = ttest2(deltaPointNeuron.allNSTDAboveMedian(delta,:),...
        deltaPointBehavNeur.allNSTDAboveMedian(delta+1,:));
    [~,pVal(delta,3)] = ttest2(deltaPointBehavNeur.allNSTDAboveMedian(delta+1,:),...
        deltaPointBehavior.allNSTDAboveMedian(delta,:));
end

%% plot 
figH = figure;
axH = axes;
hold(axH,'on');

%plot points 
meanNeuron = mean(deltaPointNeuron.nSTDAboveMedian,2);
meanBehavior = mean(deltaPointBehavior.nSTDAboveMedian,2);
meanBehaviorNeuron = mean(deltaPointBehavNeur.nSTDAboveMedian,2);
plotNeuron = plot(1:nDelta,meanNeuron);
plotBehavior = plot(1:nDelta,meanBehavior);
plotBehavNeur = plot(0:nDelta,meanBehaviorNeuron);

%set attributes
colors = distinguishable_colors(size(pVal,2));
plotNeuron.Color = colors(1,:);
plotNeuron.LineWidth = 2;
plotNeuron.Marker = 'o';
plotNeuron.MarkerSize = 13;
plotNeuron.MarkerFaceColor = colors(1,:);

plotBehavior.Color = colors(2,:);
plotBehavior.LineWidth = 2;
plotBehavior.Marker = '^';
plotBehavior.MarkerSize = 13;
plotBehavior.MarkerFaceColor = colors(2,:);

plotBehavNeur.Color = colors(3,:);
plotBehavNeur.LineWidth = 2;
plotBehavNeur.Marker = 'd';
plotBehavNeur.MarkerSize = 13;
plotBehavNeur.MarkerFaceColor = colors(3,:);

%Add statistics 
limRange = range(axH.YLim);
axH.YLim(2) = axH.YLim(2) + 0.1*limRange;
colors = 'mcy';
for delta = 1:nDelta
    allVals = cat(2,meanNeuron(delta),meanBehavior(delta),meanBehaviorNeuron(delta));
    for compInd = 1:size(pVal,2)
        if pVal(delta,compInd) <= 0.001 
            textH = text(delta,max(allVals) +...
                compInd*0.02*limRange,'***');
        elseif pVal(delta,compInd) <= 0.01
            textH = text(delta,max(allVals) +...
                compInd*0.02*limRange,'**');
        elseif pVal(delta,compInd) <= 0.05
            textH = text(delta,max(allVals) +...
                compInd*0.02*limRange,'*');
        end
        textH.HorizontalAlignment = 'Center';
        textH.VerticalAlignment = 'Middle';
        textH.FontSize = 30;
        textH.Color = colors(compInd);
    end
end

%set axis 
axis(axH,'square');
axH.FontSize = 20;
axH.LabelFontSizeMultiplier = 1.5;
axH.XLabel.String = '\Delta Maze Epochs';
axH.YLabel.String = '# Standard Deviations Above Shuffle Median';

%legend
legend([plotNeuron,plotBehavior,plotBehavNeur],{'Clustering based on neuronal data',...
    'Clustering based on behavioral data','Predict neuronal clusters based on behavioral clusters'},'Location','NorthEast');
