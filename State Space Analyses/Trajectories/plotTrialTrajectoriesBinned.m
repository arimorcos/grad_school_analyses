function figH = plotTrialTrajectoriesBinned(dataCell,conditions,varargin)
%plotTrialTrajectoriesBinned.m Plots the 3D trajectory of a population given a set of
%conditions, using bins
%
%INPUTS
%dataCell - dataCell containing imaging data
%conditions - cell rray of condition strings
%segment - which segment to plot
%
%OPTIONAL INPUTS
%colorIndividually - color each trace individually. Default is false.
%markersPerTrace - number of markers per trace. Default is 2.
%timeColor - color lines according to time. Default is false.
%whichFactorSet - which factor set to use. Default is 2.
%whichFactors - which factors to use. Default is 1:3
%binRange - range of bins to use. Default is [-20 620].
%subtractMeanVec - subtract mean vector
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
binRange = [-20 620];
subtractMeanVec = true;

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
            case 'binrange'
                binRange = varargin{argInd+1};
            case 'subtractmeanvec'
                subtractMeanVec = varargin{argInd+1};
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

%get mean subtracted traces 
condTraces = cell(1,nConditions);
if subtractMeanVec
    for condInd = 1:nConditions
        condTraces{condInd} = getMeanSubtractedTrajectories(condSub{condInd});
    end
end

%filter based on binRange
binRangeInBinNum(1) = find(binRange(1) <= dataCell{1}.imaging.yPosBins,1,'first');
binRangeInBinNum(2) = find(binRange(2) >= dataCell{1}.imaging.yPosBins,1,'last');
binsToUse = binRangeInBinNum(1):binRangeInBinNum(2);

%get distinguishable colors
colorsToPlot = distinguishable_colors(nConditions);

%check whichFactors
if length(whichFactors) == 2
    whichFactors(3) = min(size(condSub{condInd}{1}.imaging.binnedFactDFF{1}{whichFactorSet},1),whichFactors(2) + 1);
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
        nPoints = length(binsToUse);
        
        %get plotData
        if subtractMeanVec
            plotData{1} = condTraces{condInd}(whichFactors(1),:,trialInd);
            plotData{2} = condTraces{condInd}(whichFactors(2),:,trialInd);
            plotData{3} = condTraces{condInd}(whichFactors(3),:,trialInd);
        else
            plotData{1} = condSub{condInd}{trialInd}.imaging.binnedFactDFF{1}{whichFactorSet}(whichFactors(1),binsToUse);
            plotData{2} = condSub{condInd}{trialInd}.imaging.binnedFactDFF{1}{whichFactorSet}(whichFactors(2),binsToUse);
            plotData{3} = condSub{condInd}{trialInd}.imaging.binnedFactDFF{1}{whichFactorSet}(whichFactors(3),binsToUse);
        end
        
        if timeColor
            plotH{condInd}(trialInd) = surface(...
                repmat(plotData{1},2,1),...
                repmat(plotData{2},2,1),...
                repmat(plotData{3},2,1),...
                repmat(1:nPoints,2,1));
            plotH{condInd}(trialInd).FaceColor = 'no';
            plotH{condInd}(trialInd).EdgeColor = 'interp';
            colormap(jet);
        else
            
            %plot trial trace
            plotH{condInd}(trialInd) =...
                plot3(plotData{1},plotData{2},plotData{3});
            
            if ~colorIndividually
                %set color based on condition
                plotH{condInd}(trialInd).Color = colorsToPlot(condInd,:);
            end
            
            %%%%%add markers spaced out with colors for time
            
            %get marker positions 
            markerPos = linspace(1,nPoints,markersPerTrace);
            
            %plot 
            scatH = scatter3(plotData{1}(:,markerPos),plotData{2}(:,markerPos),...
                plotData{3}(:,markerPos));
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


