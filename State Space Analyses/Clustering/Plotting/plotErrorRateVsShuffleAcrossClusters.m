function plotErrorRateVsShuffleAcrossClusters(out)
%plotErrorRateVsShuffleAcrossClusters.m Plots for a single dataset the
%error rate for some number of shuffles vs. the actual error rate
%
%INPUTS
%out - output of predictError
%
%ASM 10/15

%params
nShuffleToShow = 20;
showShuffleBounds = true;
thresh = 8;

%calculate error rates
realErrorRate = out.errorCount./out.uniqueCount;
shuffleErrorRate = bsxfun(@rdivide, out.shuffleErrorCount, out.uniqueCount);

%remove data with less than thresh trials
keepInd = out.uniqueCount >= thresh;
realErrorRate = realErrorRate(keepInd);
shuffleErrorRate = shuffleErrorRate(keepInd,:);


%get nClusters
nClusters = length(realErrorRate);

%create figure
figH = figure;
axH = axes;
hold(axH,'on');

%plot shuffles
if showShuffleBounds
    shuffleBounds = fliplr(prctile(shuffleErrorRate,[2.5 97.5],2));
    shuffleBounds = abs(bsxfun(@minus, median(shuffleErrorRate, 2),...
        shuffleBounds));
    errH = shadedErrorBar(1:nClusters, median(shuffleErrorRate,2),...
        shuffleBounds, 'k');
    errH.FaceAlpha = 0.01;
    
else
    nShuffles = size(out.shuffleErrorCount,2);
    whichShuffles = randi(nShuffles,nShuffleToShow,1);
    for i = 1:nShuffleToShow
        
        shuffleH = plot(1:nClusters, shuffleErrorRate(:,whichShuffles(i)));
        gray = repmat(0.7,1,3);
        shuffleH.Color = gray;
        %     shuffleH.Marker = 'o';
        %     shuffleH.MarkerFaceColor = gray;
        %     shuffleH.MarkerEdgeColor = gray;
        %     shuffleH.LineStyle = 'none';
        
    end
end

% plot real
color = lines(1);
plotH = plot(1:nClusters, realErrorRate);
plotH.Color = color;
plotH.Marker = 'o';
plotH.MarkerFaceColor = color;
plotH.MarkerEdgeColor = color;
plotH.LineStyle = 'none';
plotH.MarkerSize = 10;

beautifyPlot(figH,axH);

axH.XLabel.String = 'Cluster';
axH.YLabel.String = 'Error rate';
axH.XLim = [0.8 nClusters+0.2];