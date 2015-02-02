function figH = plotTrialTrajectories(dataCell,conditions,varargin)
%plotTrialTrajectories.m Plots the 3D trajectory of a population given a set of
%conditions
%
%INPUTS
%dataCell - dataCell containing imaging data
%conditions - cell rray of condition strings
%segment - which segment to plot
%
%OPTIONAL INPUTS
%colorIndividually - color each trace individually
%markersPerTrace - number of markers per trace. Default is 2.
%timeColor - color lines according to time
%whichFactorSet - which factor set to use
%whichFactors - which factors to use
%
%OUTPUTS
%figH - figure handle
%
%ASM 1/15

%process varargin
whichFactorSet = 2;
whichFactors = 1:3;
markersPerTrace = 2;
timeColor = false;
colorIndividually = false;
highlightTrial = true;

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
            case 'markerspertrace'
                markersPerTrace = varargin{argInd+1};
            case 'timecolor'
                timeColor = varargin{argInd+1};
            case 'colorindividually'
                colorIndividually = varargin{argInd+1};
            case 'highlighttrial'
                highlightTrial = varargin{argInd+1};
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

%get distinguishable colors
colorsToPlot = distinguishable_colors(nConditions);

%check whichFactors
if length(whichFactors) == 2
    whichFactors(3) = whichFactors(2) + 1;
    view3D = false;
else
    view3D = true;
end

%create figure
figH = figure;
axH = axes;
hold(axH,'on');
axis square;

%get marker Colors
markerColors = jet(markersPerTrace);

%plot
plotH = cell(nConditions,1);
legendLabels = gobjects(nConditions,1);
for condInd = 1:nConditions
    
    %get nTrialConds
    nTrialsCond = length(condSub{condInd});
    plotH{condInd} = gobjects(nTrialsCond);
    
    %loop through each trial and plot trace
    for trialInd = 1:nTrialsCond
        
        %get nPoints
        nPoints = length(condSub{condInd}{trialInd}.imaging.projDFF{whichFactorSet}(whichFactors(1),:));
        
        if timeColor
            plotH{condInd}(trialInd) = surface(...
                repmat(condSub{condInd}{trialInd}.imaging.projDFF{whichFactorSet}(whichFactors(1),:),2,1),...
                repmat(condSub{condInd}{trialInd}.imaging.projDFF{whichFactorSet}(whichFactors(2),:),2,1),...
                repmat(condSub{condInd}{trialInd}.imaging.projDFF{whichFactorSet}(whichFactors(3),:),2,1),...
                repmat(1:nPoints,2,1));
            plotH{condInd}(trialInd).FaceColor = 'no';
            plotH{condInd}(trialInd).EdgeColor = 'interp';
            colormap(jet);
        else
            
            %plot trial trace
            plotH{condInd}(trialInd) =...
                plot3(condSub{condInd}{trialInd}.imaging.projDFF{whichFactorSet}(whichFactors(1),:),...
                condSub{condInd}{trialInd}.imaging.projDFF{whichFactorSet}(whichFactors(2),:),...
                condSub{condInd}{trialInd}.imaging.projDFF{whichFactorSet}(whichFactors(3),:));
            
            if ~colorIndividually
                %set color based on condition
                plotH{condInd}(trialInd).Color = colorsToPlot(condInd,:);
            end
            
            %%%%%add markers spaced out with colors for time
            
            %get marker positions
            markerPos = linspace(1,nPoints,markersPerTrace);
            
            %plot
            scatH = scatter3(condSub{condInd}{trialInd}.imaging.projDFF{whichFactorSet}(whichFactors(1),markerPos),...
                condSub{condInd}{trialInd}.imaging.projDFF{whichFactorSet}(whichFactors(2),markerPos),...
                condSub{condInd}{trialInd}.imaging.projDFF{whichFactorSet}(whichFactors(3),markerPos));
            scatH.Marker = 'o';
            scatH.SizeData = 200;
            scatH.CData = markerColors;
        end
    end
    
    %store legend label
    legendLabels(condInd) = plotH{condInd}(1);
       
end

%determine view
if view3D
    view(3);
else
    view(2);
end

%label axes
axH.XLabel.String = sprintf('Factor %d',whichFactors(1));
axH.YLabel.String = sprintf('Factor %d',whichFactors(2));
if length(whichFactors) == 3
    axH.ZLabel.String = sprintf('Factor %d',whichFactors(3));
end

%create legend
if nConditions > 1
    legend(legendLabels,conditions,'Location','BestOutside');
end

if highlightTrial
    
    highlightProp.Handle = [];
    highlightProp.currTrace = 0;
    figH.UserData = highlightProp;
    
    %get all trials which match conditions
    allConds = cat(2,condSub{:});
    
    %create callback to change highlighted trace
    figH.KeyPressFcn = {@cb_keypress,allConds,conditions,whichFactorSet,...
        whichFactors,legendLabels};
    
end

end

function cb_keypress(src,evnt,dataCell,conditions,whichFactorSet,whichFactors,legendLabels)
%highlights single trace in black based on arrow keys

%check if trace exists already
if ishandle(src.UserData.Handle)
    delete(src.UserData.Handle);
end

%get trace to plot
switch evnt.Key
    case 'rightarrow'
        src.UserData.currTrace = src.UserData.currTrace + 1;
        if src.UserData.currTrace > length(dataCell)
            src.UserData.currTrace = 0;
            return;
        end
    case 'leftarrow'
        src.UserData.currTrace = src.UserData.currTrace - 1;
        if src.UserData.currTrace <= 0
            src.UserData.currTrace = 0;
            return;
        end
end

%plot trace
src.UserData.Handle =...
    plot3(dataCell{src.UserData.currTrace}.imaging.projDFF{whichFactorSet}(whichFactors(1),:),...
    dataCell{src.UserData.currTrace}.imaging.projDFF{whichFactorSet}(whichFactors(2),:),...
    dataCell{src.UserData.currTrace}.imaging.projDFF{whichFactorSet}(whichFactors(3),:));
src.UserData.Handle.LineWidth = 2;
src.UserData.Handle.Color = 'k';

%update legend 

delete(src.Children(1)); %delete current legend
currCond = conditions(cellfun(@(x) findTrials(dataCell(src.UserData.currTrace),x),conditions));
legend(cat(1,legendLabels,src.UserData.Handle),cat(2,conditions{:},currCond),'Location','BestOutside');

end