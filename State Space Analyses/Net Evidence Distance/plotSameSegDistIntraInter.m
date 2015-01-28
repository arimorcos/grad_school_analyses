function [figH,axH] = plotSameSegDistIntraInter(data,figH,axH,varargin)
%plotSameSegDistIntraInter.m  Plots interNetEv - intraNetEv with
%significance for each segment individually
%
%INPUTS
%data - output of compareSegDistances
%figH - figure handle
%axH - axes handle
%
%OUTPUTS
%figH - figure handle
%axH - axis handle
%
%ASM 8/14

if nargin < 2 || isempty(figH) 
    figH = figure;
    axH = axes;
elseif nargin < 3 || isempty(axH) 
    axH = axes;
else
    set(0,'CurrentFigure',figH);
    axes(axH);
end

%initialize
prctileVals = [0.5 99.5];
shuffleColor = [1 0 0];
labelFont = 30;
axisFont = 20;
titleStr = [];

%process varargin
if nargin > 3 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'prctilevals'
                prctileVals = varargin{argInd+1};
            case 'shufflecolor'
                shuffleColor = varargin{argInd+1};
            case 'labelfont'
                labelFont = varargin{argInd+1};
            case 'axisfont'
                axisFont = varargin{argInd+1};
            case 'titlestr'
                titleStr = varargin{argInd+1};
        end
    end
end

%get prctile of range for shuffle
shuffleRange = prctile(data.shuffledMeansDiffSameSegNetEv,prctileVals,2);

%plot bar graph
yData = data.meanDiffNetEvSameSegDist;
xData = 1:data.nSeg;
bar(xData,yData);
hold on;
% patchHandle=patch(cat(1,xData',fliplr(xData)'),shuffleRange(:),...
%     shuffleColor);
% set(patchHandle,'FaceAlpha',shuffleAlpha,'EdgeColor',shuffleColor);
errorbar(xData,zeros(size(xData)),abs(shuffleRange(:,1)),abs(shuffleRange(:,2)),...
    'LineStyle','none','Color',shuffleColor,'LineWidth',2);
ylabel('Inter Net Evidence - Intra Net Evidence (dF/F)','FontSize',labelFont);
xlabel('Segment #','FontSize',labelFont);
set(axH,'FontSize',axisFont);
title(titleStr,'FontSize',labelFont);