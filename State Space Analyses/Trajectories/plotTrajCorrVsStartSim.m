function plotTrajCorrVsStartSim(dataCell,axH)
%plotTrajCorrVsStartSim.m Plots trajectory correlation as a function of
%start point similarity 
%
%INPUTS
%dataCell
%
%ASM 1/15

if nargin < 2 
    axH = [];
end

WHICH_FACTORS = 3:5;

%trial range  
binRange = [-5 600];
startBinNum = find(dataCell{1}.imaging.yPosBins > binRange(1),1,'first');
endBinNum = find(dataCell{1}.imaging.yPosBins < binRange(2),1,'last');

%get binned traces 
traces = catBinnedFactors(dataCell,2);

%get trial trajectories 
traces = traces(:,startBinNum:endBinNum,:);

%get turn 
turn = getCellVals(dataCell,'result.leftTurn');

%get correlations 
[startDistVec,trajCorrVec,compLabel] = getTrajCorrVsStartDist(traces,turn,WHICH_FACTORS);

%plot
%create figure
if isempty(axH)
    figH = figure;
    axH = axes;
    %create colors 
    colorsToPlot = distinguishable_colors(3);
else
    figH = axH.Parent;
    hold(axH,'on');
    %get number of children
    nChildren = length(axH.Children);
    colorsToPlot = distinguishable_colors(nChildren+3);
    colorsToPlot = colorsToPlot(end-2:end,:);
end

%scatter correlation values 
plotH = gscatter(startDistVec,trajCorrVec,compLabel);
plotH(1).DisplayName = 'Right-Right Comparison';
plotH(2).DisplayName = 'Left-Right Comparison';
plotH(3).DisplayName = 'Left-Left Comparison';
for i = 1:length(plotH)
    plotH(i).MarkerSize = 10;
    plotH(i).Color = colorsToPlot(i,:);
end

%label axes
axH.XLabel.String = 'Start Point Distance';
axH.YLabel.String = 'Trajectory Correlation';

end 

function [startDistVec,trajCorrVec,compLabel] = getTrajCorrVsStartDist(traces,turn,whichFactors)

%get nTrials
nTrials = size(traces,3);

%calculate pairwise correlation coefficient between trajectories
trajCorrMat = nan(nTrials);
compLabel = nan(nTrials);
for rowInd = 1:nTrials
    for colInd = rowInd+1:nTrials
        trajCorrMat(rowInd,colInd) = corr2(traces(whichFactors,2:end,rowInd),traces(whichFactors,2:end,colInd));
        if turn(rowInd) && turn(colInd)
            compLabel(rowInd,colInd) = 1;
        elseif ~turn(rowInd) && ~turn(colInd)
            compLabel(rowInd,colInd) = -1;
        else
            compLabel(rowInd,colInd) = 0;
        end
    end
end

%calculate pairwise correlation coefficient between starting point
startDistMat = nan(nTrials);
for rowInd = 1:nTrials
    for colInd = rowInd+1:nTrials
        startDistMat(rowInd,colInd) = calcEuclidianDist(traces(whichFactors,1,rowInd),traces(whichFactors,1,colInd));
    end
end

%sort both as vectors 
startDistVec = startDistMat(:);
startDistVec = startDistVec(~isnan(startDistVec));
trajCorrVec = trajCorrMat(:);
trajCorrVec = trajCorrVec(~isnan(trajCorrVec));
compLabel = compLabel(:);
compLabel = compLabel(~isnan(compLabel));

end



