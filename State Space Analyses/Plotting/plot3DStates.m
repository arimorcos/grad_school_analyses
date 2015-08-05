function figH = plot3DStates(dataCell,conditions,segment,varargin)
%plot3DStates.m Plots the 3D state of a population given a set of
%conditions
%
%INPUTS
%dataCell - dataCell containing imaging data
%conditions - cell rray of condition strings
%segment - which segment to plot
%
%OPTIONAL INPUTS
%whichFactorSet - which factor set to use
%whichFactors - which factors to use
%showViewAngle - show line with view angle points as well
%
%OUTPUTS
%figH - figure handle
%
%ASM 1/15

%process varargin
whichFactorSet = 1;
whichFactors = 1:3;
showViewAngle = false;

if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'whichfactorset'
                whichFactorSet = varargin{argInd+1};
            case 'whichfactors'
                whichFactors = varargin{argInd+1};
            case 'showviewangle'
                showViewAngle = varargin{argInd+1};
        end
    end
end

%check inputs
assert(iscell(conditions),'Conditions must be a cell array');

%get nConditions
nConditions = length(conditions);

%extract conditions
condSub = cell(1,nConditions);
for condInd = 1:nConditions
    condSub{condInd} = getTrials(dataCell,conditions{condInd});
end

%get segment traces
condSegTraces = cell(1,nConditions);
condVA = cell(1,nConditions);
for condInd = 1:nConditions
    [condSegTraces{condInd},~,~,~,~,~,~,~,condVA{condInd}] =...
        extractSegmentTraces(condSub{condInd},'traceType','dffFactor',...
        'whichFactor',whichFactorSet,'outputTrials',true);
    
    %subset factors and segment
    condSegTraces{condInd} = squeeze(condSegTraces{condInd}(whichFactors,segment,:));
    condVA{condInd} = squeeze(condVA{condInd}(:,segment));
end

%get distinguishable colors
colorsToPlot = distinguishable_colors(nConditions);

%create figure
figH = figure;
axH = axes;
hold on;
axis square;

%plot
plotH = gobjects(nConditions);
for condInd = 1:nConditions
    if length(whichFactors) == 3
        plotH(condInd) = plot3(condSegTraces{condInd}(1,:), condSegTraces{condInd}(2,:),...
            condSegTraces{condInd}(3,:));
        view(3);
    else
        plotH(condInd) = plot(condSegTraces{condInd}(1,:), condSegTraces{condInd}(2,:));
    end
    plotH(condInd).Color = colorsToPlot(condInd,:);
    plotH(condInd).LineStyle = 'none';
    plotH(condInd).Marker = 'o';
    plotH(condInd).LineWidth = 2;
end

%label axes
axH.XLabel.String = sprintf('Factor %d',whichFactors(1));
axH.YLabel.String = sprintf('Factor %d',whichFactors(2));
if length(whichFactors) == 3
    axH.ZLabel.String = sprintf('Factor %d',whichFactors(3));
end

%plot view angle 
if showViewAngle 
   %create colorbar to get easy position
   cbH = colorbar;
   newPos = cbH.Position;
   delete(cbH);
   
   %create new axes using cb position
   vaH = axes;
   hold(vaH,'on');
   vaH.Position = newPos;
   vaH.XTick = [];
   
   %plot view angle
   vaScatH = gobjects(nConditions,1);
   for condInd = 1:nConditions
       vaScatH(condInd) = scatter(condInd*ones(size(condVA{condInd}))/nConditions,condVA{condInd});
       vaScatH(condInd).MarkerEdgeColor = colorsToPlot(condInd,:);
       vaScatH(condInd).LineWidth = 2;
   end
end

%Create legend
legend(conditions,'Location','BestOutside');


