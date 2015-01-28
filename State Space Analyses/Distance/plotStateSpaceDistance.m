function plotStateSpaceDistance(in)
%plotStateSpaceDistance.m Plots state space data
%
%INPUTS
%in - array containing output of calcStateSpaceDistance.m 
%
%ASM 11/13

%replace conditions{2} with all if empty
if isempty(in.conditions{2})
    in.conditions{2} = 'all else';
end

%check if conditions{1} is numeric
if isnumeric(in.conditions{1})
    in.conditions{1} = ['pattern ', sprintf('%d ',in.conditions{1})];
end

%initialize sizes
labelSize = 20;
axesSize = 15;

%create figure
figure('Name',sprintf('State Space Distance for %s vs. %s',...
    in.conditions{1},in.conditions{2}),'Numbertitle','off');

%plot sem over time
intraPlot = shadedErrorBar(in.yPosBins,in.intraDistancesMean,in.intraDistanceSEM,...
    'b-');
hold on;
interPlot = shadedErrorBar(in.yPosBins,in.interDistancesMean,in.interDistanceSEM,...
    'r-');

%label axes
set(gca,'FontSize',axesSize);
ylabel('N-dimensional distance','FontSize',labelSize);
xlabel('Y Position','FontSize',labelSize);

%legend
legend([intraPlot.mainLine interPlot.mainLine],{sprintf('within %s',in.conditions{1}),...
    sprintf('between %s and %s',in.conditions{1},in.conditions{2})},'Location','SouthWest');
