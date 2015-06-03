function plotDeltaPLeftVsEpoch(deltaPLeft)
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
figH = figure;
axH = axes; 

%get mean and sem 
transMean = nanmean(abs(deltaPLeft));
transSEM = calcSEM(abs(deltaPLeft));

%plot 
errH = shadedErrorBar(1:size(deltaPLeft,2),transMean,transSEM);

%beautify 
beautifyPlot(figH,axH);

%label 
axH.XTickLabel = pointLabels;
axH.XTickLabelRotation = -45;
axH.YLabel.String = '\Delta P(Left Turn)';
