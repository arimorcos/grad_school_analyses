function plotClusterOverlapCorrAcrossEpochs(overlapIndex,clusterCorr,...
    transMat,deltaEpochs)
%plotClusterOverlapCorrAcrossEpochs.m Plots the output of
%clusterOverlapCorrAcrossEpochs
%
%INPUTS
%%overlapIndex - nTotalClusters x nTotalClusters array of overlap indices
%clusterCorr - nTotalClusters x nTotalClusters array of correlation
%   coefficients
%transMat - nTotalClusters x nTotalClusters array of transition
%   probabilities
%deltaEpochs - nTotalClusters x nTotalClusters array of epochs separating
%   clusters
%
%ASM 10/15

% convert everything to triangular matrix 
nTotal = length(overlapIndex);
nanInd = ~logical(triu(ones(nTotal),1));
overlapIndex(nanInd) = NaN;
clusterCorr(nanInd) = NaN;
deltaEpochs(nanInd) = NaN;

% convert to vectors 
overlapVec = overlapIndex(:);
clusterCorrVec = clusterCorr(:);
deltaEpochVec = deltaEpochs(:);
transMatVec = transMat(:);

% filter 
removeInd = nanInd(:);
overlapVec(removeInd) = [];
clusterCorrVec(removeInd) = [];
deltaEpochVec(removeInd) = [];
transMatVec(removeInd) = [];

%% calculate stats 
whichDelta = unique(deltaEpochVec);
nDelta = length(whichDelta);

% loop through and get mean for each 
overlapDelta = nan(nDelta,1);
meanCorrDelta = nan(nDelta,1);
maxCorrDelta = nan(nDelta,1);
transProbLM = cell(nDelta,1);
for delta = 1:nDelta
    keepInd = deltaEpochVec == whichDelta(delta);
    overlapDelta(delta) = nanmean(overlapVec(keepInd));
    meanCorrDelta(delta) = nanmean(clusterCorrVec(keepInd));
    maxCorrDelta(delta) = max(clusterCorrVec(keepInd));
    
    transProbLM{delta} = fitlm(transMatVec(keepInd), clusterCorrVec(keepInd));
end


%% create figure 
figH = figure;

%% plot overlap vs. delta epochs 
axH = subplot(2, 2, 1);

plotOverlap = plot(whichDelta, overlapDelta);

beautifyPlot(figH, axH);
axH.XLabel.String = '\Delta epochs';
axH.YLabel.String = 'Overlap index';

%% plot corr vs. delta epochs 
axH = subplot(2, 2, 2);
hold(axH,'on');

plotMeanCorr = plot(whichDelta, meanCorrDelta);
plotMaxCorr = plot(whichDelta, maxCorrDelta);

beautifyPlot(figH, axH);
axH.XLabel.String = '\Delta epochs';
axH.YLabel.String = 'Correlation coefficient';
legend({'Mean','Max'},'Location','best');

%% plot corr vs. trans probability 

axH = subplot(2, 2, 3);
hold(axH, 'on')

legEnt = cell(nDelta-1,1);
xVals = 0:0.1:1;
slope = nan(nDelta-1,1);
for delta = 2:nDelta
    
    plot(xVals, predict(transProbLM{delta}, xVals'));
    
    legEnt{delta-1} = sprintf('%d',whichDelta(delta));
    slope(delta-1) = transProbLM{delta}.Coefficients.Estimate(2);
    
end

beautifyPlot(figH, axH);
axH.XLabel.String = 'Transition probability';
axH.YLabel.String = 'Correlation coefficient';
legend(legEnt,'Location','best');

%% plot slope 

axH = subplot(2, 2, 4);

plotSlope = plot(whichDelta(2:end), slope);

beautifyPlot(figH, axH);
axH.XLabel.String = '\Delta epochs';
axH.YLabel.String = 'Corr. vs. trans. prob. slope';


