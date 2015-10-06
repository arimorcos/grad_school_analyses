function plotConditionalPairwiseCorrelation(out)
%plotConditionalPairwiseCorrelation.m Plots the output of
%getConditionalPairwiseCorrelation
%
%INPUTS
%out - output of getConditionalPairwiseCorrelation
%
%ASM 10/15

%create figure
figH = figure;
axH = axes;
cmScale = 0.75;

%turn on hold
hold(axH, 'on');

%get colors 
colors = lines(3);

%plot all 
xVals = cmScale*out.yPosBins;
meanAll = mean(out.allCorr);
semAll = calcSEM(out.allCorr);
allPlot = shadedErrorBar(xVals, meanAll, semAll);
allPlot.mainLine.Color = colors(1,:);
allPlot.patch.FaceColor = colors(1,:);
allPlot.patch.FaceAlpha = 0.3;
allPlot.edge(1).Color = colors(1,:);
allPlot.edge(2).Color = colors(1,:);

%plot turn 
meanTurn = mean(out.turnCorr);
semTurn = calcSEM(out.turnCorr);
turnPlot = shadedErrorBar(xVals, meanTurn, semTurn);
turnPlot.mainLine.Color = colors(2,:);
turnPlot.patch.FaceColor = colors(2,:);
turnPlot.patch.FaceAlpha = 0.3;
turnPlot.edge(1).Color = colors(2,:);
turnPlot.edge(2).Color = colors(2,:);

%plot 6-0 turn 
meanTurn60 = mean(out.turn60Corr);
semTurn60 = calcSEM(out.turn60Corr);
turn60Plot = shadedErrorBar(xVals, meanTurn60, semTurn60);
turn60Plot.mainLine.Color = colors(3,:);
turn60Plot.patch.FaceColor = colors(3,:);
turn60Plot.patch.FaceAlpha = 0.3;
turn60Plot.edge(1).Color = colors(3,:);
turn60Plot.edge(2).Color = colors(3,:);

%beautify 
beautifyPlot(figH, axH);

%label
axH.XLabel.String = 'Maze position (cm)';
axH.YLabel.String = 'Pairwise trial-trial correlation coefficient';

%legend
legH = legend([allPlot.mainLine, turnPlot.mainLine, turn60Plot.mainLine],...
    {'All trials','Same turn trials','Same turn 6-0 trials'},'Location',...
    'NorthWest');

