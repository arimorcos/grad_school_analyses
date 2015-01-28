function figH = plotOverlappingPopulations(pops,conds,varargin)
%plotOverlappingPopulations.m Plots output of findOverlapping populations
%
%INPUTS
%pops - nCells x nConds logical of whether cell is active during that
%   condition or not
%conds - 1 x nConds cell array of conditions compared
%
%VARIABLE INPUTS
%plotType - type of plot. 
%
%OUTPUTS
%figH - figure handle
%
%ASM 11/14

%process varargin
plotType = 'adjMat';

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'plottype'
                plotType = varargin{argInd+1};
        end
    end
end

%create figure
figH = figure;

%plot depending on plot type
switch lower(plotType)
    case 'adjmat'
        plotAdjMat(pops,conds);
end


end

function plotAdjMat(pops,conds)

%%%%calculate overlap for each condition combination

%get nConds
nConds = length(conds);

%initialize
adjMat = zeros(nConds);


%loop through each combination and perform computations
for firstInd = 1:nConds
    for secondInd = 1:nConds
        
        adjMat(firstInd,secondInd) = ...
            sum(pops(:,firstInd) & pops(:,secondInd))/... %intersect
            sum(pops(:,firstInd) | pops(:,secondInd)); %union
    end
end

%plot
adjMatPlot = imagesc(adjMat);
adjMatPlot.Parent.XTick = 1:nConds;
adjMatPlot.Parent.XTickLabel = conds;
adjMatPlot.Parent.YTick = 1:nConds;
adjMatPlot.Parent.YTickLabel = conds;
adjMatPlot.Parent.XTickLabelRotation = 30;
adjMatPlot.Parent.YTickLabelRotation = 0;
adjMatPlot.Parent.FontSize = 15;
cBar = colorbar;
cBar.YLabel.String = 'Overlap Index (intersection/union)';
cBar.Limits = [0 1];
cBar.YLabel.FontSize = 30;
cBar.YLabel.Rotation = 270;
cBar.YLabel.VerticalAlignment = 'Bottom';
cBar.FontSize = 20;

end

