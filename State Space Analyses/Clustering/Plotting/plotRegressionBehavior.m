function plotRegressionBehavior(in)
%plotRegressionBehavior.m Plots the output of regressClustBehavior
%
%INPUTS
%in - structure output by regressClustBehavior
%
%ASM 7/15

%% take averages across diagonals 

%get nPoints
nPoints = length(in.adjR2Behav);

%get distance matrix
pointDist = triu(squareform(pdist((1:nPoints)')));

%initialize regular 
adjR2BehavDelta = nan(nPoints,1);
adjR2BehavNeurDelta = nan(size(adjR2BehavDelta));
RMSEBehavDelta = nan(size(adjR2BehavDelta));
RMSEBehavNeurDelta = nan(size(adjR2BehavDelta));

%initialize shuffles
nShuffles = size(in.adjR2BehavShuffle,3);
adjR2BehavDeltaShuffle = nan(nPoints,nShuffles);
adjR2BehavNeurDeltaShuffle = nan(size(adjR2BehavDeltaShuffle));
RMSEBehavDeltaShuffle = nan(size(adjR2BehavDeltaShuffle));
RMSEBehavNeurDeltaShuffle = nan(size(adjR2BehavDeltaShuffle));

%loop through each transition 
for delta = 0:(nPoints-1)
    
    %get matchInd
    if delta > 0
        matchInd = pointDist == delta;
    else
        matchInd = sub2ind([nPoints nPoints],1:nPoints,1:nPoints);
    end
    
    % take mean of matching indices for regulars 
    adjR2BehavDelta(delta+1) = nanmean(in.adjR2Behav(matchInd));
    adjR2BehavNeurDelta(delta+1) = nanmean(in.adjR2BehavNeur(matchInd));
    RMSEBehavDelta(delta+1) = nanmean(in.RMSEBehav(matchInd));
    RMSEBehavNeurDelta(delta+1) = nanmean(in.RMSEBehavNeur(matchInd));
    
    % take mean of matching indices for shuffles 
    for shuffleInd = 1:nShuffles 
        
%         tempAdjR2BehavShuffle = in.adjR2BehavShuffle(:,:,shuffleInd);
%         adjR2BehavDeltaShuffle(delta+1,shuffleInd) = nanmean(tempAdjR2BehavShuffle(matchInd));
        
        tempAdjR2BehavNeurShuffle = in.adjR2BehavNeurShuffle(:,:,shuffleInd);
        adjR2BehavNeurDeltaShuffle(delta+1,shuffleInd) = nanmean(tempAdjR2BehavNeurShuffle(matchInd));
        
%         tempRMSEBehavShuffle = in.RMSEBehavShuffle(:,:,shuffleInd);
%         RMSEBehavDeltaShuffle(delta+1,shuffleInd) = nanmean(tempRMSEBehavShuffle(matchInd));
        
        tempRMSEBehavNeurShuffle = in.RMSEBehavNeurShuffle(:,:,shuffleInd);
        RMSEBehavNeurDeltaShuffle(delta+1,shuffleInd) = nanmean(tempRMSEBehavNeurShuffle(matchInd));
    end  
    
end

%% get percentiles 
%adjR2Behav
% medianAdjR2BehavShuffle = median(adjR2BehavDeltaShuffle,2);
% adjR2BehavShuffleConfInt = prctile(adjR2BehavDeltaShuffle,[2.5 97.5],2);
% adjR2BehavShuffleConfInt = bsxfun(@minus, adjR2BehavShuffleConfInt, medianAdjR2BehavShuffle);

%adjR2BehavNeur
medianAdjR2BehavNeurShuffle = median(adjR2BehavNeurDeltaShuffle,2);
adjR2BehavNeurShuffleConfInt = prctile(adjR2BehavNeurDeltaShuffle,[2.5 97.5],2);
adjR2BehavNeurShuffleConfInt = abs(bsxfun(@minus, adjR2BehavNeurShuffleConfInt, medianAdjR2BehavNeurShuffle));

%RMSEBehav
% medianRMSEBehavShuffle = median(RMSEBehavDeltaShuffle,2);
% RMSEBehavShuffleConfInt = prctile(RMSEBehavDeltaShuffle,[2.5 97.5],2);
% RMSEBehavShuffleConfInt = bsxfun(@minus, RMSEBehavShuffleConfInt, medianRMSEBehavShuffle);

%RMSEBehavNeur
medianRMSEBehavNeurShuffle = median(RMSEBehavNeurDeltaShuffle,2);
RMSEBehavNeurShuffleConfInt = prctile(RMSEBehavNeurDeltaShuffle,[2.5 97.5],2);
RMSEBehavNeurShuffleConfInt = abs(bsxfun(@minus, RMSEBehavNeurShuffleConfInt, medianRMSEBehavNeurShuffle));

%% plot 

%create figure 
figH = figure; 

%%%%%%%%%%%%%%%%create R2 plot  %%%%%%%%%%%%%%%%%%%%%%
%create subplot
axR2 = subplot(1,2,1);
hold(axR2,'on');

%plot behavior 
xVals = 0:(nPoints-1);
plotBehavR2 = plot(xVals, adjR2BehavDelta);
plotBehavR2.Color = 'r';
plotBehavR2.LineWidth = 2;

%plot clusters 
plotClustR2 = plot(xVals, adjR2BehavNeurDelta);
plotClustR2.Color = 'b';
plotClustR2.LineWidth = 2;

%plot shuffles 
plotErrorR2 = shadedErrorBar(xVals, medianAdjR2BehavNeurShuffle, fliplr(adjR2BehavNeurShuffleConfInt), 'g');
plotErrorR2.patch.FaceAlpha = 0.4;

%beautify 
beautifyPlot(figH, axR2);

%label
axR2.YLabel.String = 'Adjusted R^{2}';
%%%%%%%%%%%%%%%%create RMSE plot  %%%%%%%%%%%%%%%%%%%%%%
%create subplot
axRMSE = subplot(1,2,2);
hold(axRMSE,'on');

%plot behavior 
xVals = 0:(nPoints-1);
plotBehavRMSE = plot(xVals, RMSEBehavDelta);
plotBehavRMSE.Color = 'r';
plotBehavRMSE.LineWidth = 2;

%plot clusters 
plotClustRMSE = plot(xVals, RMSEBehavNeurDelta);
plotClustRMSE.Color = 'b';
plotClustRMSE.LineWidth = 2;

%plot shuffles 
plotErrorRMSE = shadedErrorBar(xVals, medianRMSEBehavNeurShuffle, fliplr(RMSEBehavNeurShuffleConfInt), 'g');
plotErrorRMSE.patch.FaceAlpha = 0.4;

%beautify 
beautifyPlot(figH, axRMSE);

%label
axRMSE.YLabel.String = 'RMSE';

%add legend 
legend([plotBehavRMSE, plotClustRMSE, plotErrorRMSE.mainLine],...
    {'Behavior Only','Behavior + Neuronal Clusters', 'Behavior + Shuffled Clusters'},...
    'Location','NorthWest');

%%%% finish labeling 

%add xlabel
[~,xLab] = suplabel('\Delta Maze Epochs','x',[0.13 0.2 0.775 0.815]);
xLab.FontSize = 30;
end

