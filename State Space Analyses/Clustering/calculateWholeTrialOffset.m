function [actualMSE,shuffleMSE] = calculateWholeTrialOffset(dataCell,varargin)
%calculateWholeTrialOffset.m Calculates the offset between any two
%arbitrary points. Defaults to maze start and late delay.
%
%INPUTS
%dataCell - dataCell containing imaging data 
%
%ASM 4/15

shouldPlot = true;
nShuffles = 1000;
shouldShuffle = true;
confInt = 95;
refPoints = [1 4];
plotMSE = true;
distType = 'seuclidean';
pointLabels = {'Maze Start','Segment 1','Segment 2','Segment 3','Segment 4',...
    'Segment 5','Segment 6','Early Delay','Late Delay','Turn'};
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'shouldplot'
                shouldPlot = varargin{argInd+1};
            case 'shouldshuffle'
                shouldShuffle = varargin{argInd+1};
            case 'nshuffles'
                nShuffles = varargin{argInd+1};
            case 'confint'
                confInt = varargin{argInd+1};
            case 'refpoints'
                refPoints = varargin{argInd+1};
            case 'disttype'
                distType = varargin{argInd+1};
            case 'plotmse'
                plotMSE = varargin{argInd+1};
            case 'pointlabels'
                pointLabels = varargin{argInd+1};
        end
    end
end

%get traces
[~,traces] = catBinnedTraces(dataCell);

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%get tracePoints
tracePoints = getMazePoints(traces,yPosBins);

%get start and end points 
startPoint = squeeze(tracePoints(:,refPoints(1),:))';
endPoint = squeeze(tracePoints(:,refPoints(2),:))';

%calculate pairwise distance between starting points 
startDists = pdist(startPoint,distType);
endDists = pdist(endPoint,distType);

%calculate mse 
actualMSE = getMSEDist(startDists,endDists);

%shuffle 
if shouldShuffle
    shuffleMSE = nan(nShuffles,1);
    for shuffleInd = 1:nShuffles
        shuffleMSE(shuffleInd) = getMSEDist(shuffleArray(startDists),...
            shuffleArray(endDists));
    end
end

%% plot 
if ~shouldPlot
    return;
end

%create figure and axes 
figH = figure;

%scatter plot
if plotMSE
    axScatter = subplot(1,2,1);
else 
    axScatter = axes;
end
hold(axScatter,'on');
allDists = cat(1,startDists,endDists);
minDist = min(allDists(:));
maxDist = max(allDists(:));
scatH = scatter(startDists,endDists);

%add line of unity 
unityH = line([minDist maxDist],[minDist maxDist]);
unityH.Color = 'k';
unityH.LineStyle = '--';

%label, square, etc.
axScatter.XLabel.String = sprintf('%s Distance (%s)',pointLabels{refPoints(1)},distType);
axScatter.YLabel.String = sprintf('%s Distance (%s)',pointLabels{refPoints(2)},distType);
axScatter.XLabel.FontSize = 30;
axScatter.YLabel.FontSize = 30;
axis(axScatter,'square');
axScatter.XLim = [minDist maxDist];
axScatter.YLim = [minDist maxDist];
axScatter.FontSize = 20;

%calculate correlation coefficient 
[corr,pVal] = corrcoef(startDists,endDists);
textH = text(minDist+0.4,maxDist-0.4,sprintf('R^{2}: %.3f, p = %.4d',corr(2,1)^2,pVal(2,1)));
textH.FontSize = 20;
textH.VerticalAlignment = 'top';
textH.HorizontalAlignment = 'Left';

if ~plotMSE
    return;
end
% mse plot 
axMSE = subplot(1,2,2);
hold(axMSE,'on');

%get confidence intervals and shuffle median 
shuffleMedian = median(shuffleMSE);
highInd = (100-confInt)/2;
lowInd = 100 - highInd;
confVals = prctile(shuffleMSE,[lowInd, highInd]);
confVals = abs(shuffleMedian - confVals);

%scatter 
scatMSE = scatter(1,actualMSE);
scatMSE.MarkerFaceColor = 'b';
scatMSE.MarkerEdgeColor = 'b';
scatMSE.SizeData = 150;

%errorbar 
errMSE = errorbar(1,shuffleMedian,confVals(1),confVals(2));
errMSE.LineWidth = 2;
errMSE.Color = 'r';

%label axes 
axis(axMSE,'square');
axMSE.XTick = [];
axMSE.YLabel.String = 'Mean Squared Error';
axMSE.YLabel.FontSize = 30;
axMSE.FontSize = 20;
axMSE.XLim = [0.9 1.1];


end

function mse = getMSEDist(startDist,endDist)
    mse = mean((endDist - startDist).^2);
end
