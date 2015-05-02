function plotClustersInBehavSpace(clusterIDs,dataCell,whichPoint)
%plotClustersinBehavSpace.m Plots cluster in behavioral space
%
%INPUTS
%clusterIDs - nTrials x nPoints array of clusterIDs
%dataCell - dataCell containing imaging data
%whichPoint - which point to plot
%
%ASM 4/15

%crop clusterIDs 
if size(clusterIDs,2) > 1
    clusterIDs = clusterIDs(:,whichPoint);
end

%get binned traces
binnedDF = catBinnedDataFrames(dataCell);

%bin into maze points
dfPoints = getMazePoints(binnedDF,dataCell{1}.imaging.yPosBins);

%get xPos,yPos,theta
xPos = squeeze(dfPoints(2,whichPoint,:));
yPos = squeeze(dfPoints(3,whichPoint,:));
theta = rad2deg(squeeze(dfPoints(4,whichPoint,:))) - 90;
xVel = squeeze(dfPoints(5,whichPoint,:));
yVel = squeeze(dfPoints(6,whichPoint,:));

axLabels = {'X Position','Y Position','View Angle','X Velocity','Y Velocity'};

%concatenate 
behavVar = cat(2,xPos,yPos,theta,xVel,yVel);

%nPlots
nPlots = nchoosek(size(behavVar,2),2);
plotComb = allcomb(1:size(behavVar,2),1:size(behavVar,2));
plotComb = plotComb(plotComb(:,1) ~= plotComb(:,2),:);

%create figure
figH = figure;

%get unique clusters
uniqueClusters = unique(clusterIDs);

%get colors
colors = distinguishable_colors(length(uniqueClusters));

%get nrows
[nRows, nCol] = calcNSubplotRows(nPlots);

%loop through each plot
for plotInd = 1:nPlots
    axH = subplot(nRows,nCol,plotInd);
    axis(axH,'square');
    hold(axH,'on');
    
    
    %loop through and plot
    for clusterInd = 1:length(uniqueClusters)
        
        matchInd = uniqueClusters(clusterInd) == clusterIDs;
        scatH = scatter(behavVar(matchInd,plotComb(plotInd,1)),...
            behavVar(matchInd,plotComb(plotInd,2)));
        scatH.MarkerFaceColor = colors(clusterInd,:);
        scatH.MarkerEdgeColor = colors(clusterInd,:);
        scatH.SizeData = 50;
        
    end
    
    %label axes
    axH.FontSize = 20;
    axH.XLabel.String = axLabels{plotComb(plotInd,1)};
    axH.YLabel.String = axLabels{plotComb(plotInd,2)};
    axH.LabelFontSizeMultiplier = 1.2;
    
end


