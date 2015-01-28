%% same segment net evidence left/right separate
figH = figure;
axH1 = subplot(1,2,1);
plotSameSegDistIntraInter(outLeft,figH,axH1,'titleStr','Correct Left Trials','labelFont',20);
axH2 = subplot(1,2,2);
plotSameSegDistIntraInter(outRight,figH,axH2,'titleStr','Correct Right Trials','labelFont',20);

%% plot intra vs. inter for each condition first segment
segToPlot = 1;
figure;
subplot(1,2,1);
hold on;
rightRight = scatter(ones(length(outRight.netEvSameSegDist{6,6,segToPlot}),1)+...
    0.1*randn(length(outRight.netEvSameSegDist{6,6,segToPlot}),1),outRight.netEvSameSegDist{6,6,segToPlot},'r');
leftLeft = scatter(2*ones(length(outRight.netEvSameSegDist{8,8,segToPlot}),1)+...
    0.1*randn(length(outRight.netEvSameSegDist{8,8,segToPlot}),1),outRight.netEvSameSegDist{8,8,segToPlot},'b');
rightLeft = scatter(3*ones(length(outRight.netEvSameSegDist{8,6,segToPlot}),1)+...
    0.1*randn(length(outRight.netEvSameSegDist{8,6,segToPlot}),1),outRight.netEvSameSegDist{8,6,segToPlot},'g');
xlim([0 4]);
set(gca,'xtick',[1 2 3],'xticklabel',{'rightRight','leftLeft','rightLeft'});
title('Correct right trials');
subplot(1,2,2);
hold on;
rightRight = scatter(ones(length(outLeft.netEvSameSegDist{2,2,segToPlot}),1)+...
    0.1*randn(length(outLeft.netEvSameSegDist{2,2,segToPlot}),1),outLeft.netEvSameSegDist{2,2,segToPlot},'r');
leftLeft = scatter(2*ones(length(outLeft.netEvSameSegDist{4,4,segToPlot}),1)+...
    0.1*randn(length(outLeft.netEvSameSegDist{4,4,segToPlot}),1),outLeft.netEvSameSegDist{4,4,segToPlot},'b');
rightLeft = scatter(3*ones(length(outLeft.netEvSameSegDist{4,2,segToPlot}),1)+...
    0.1*randn(length(outLeft.netEvSameSegDist{4,2,segToPlot}),1),outLeft.netEvSameSegDist{4,2,segToPlot},'g');
xlim([0 4]);
set(gca,'xtick',[1 2 3],'xticklabel',{'rightRight','leftLeft','leftRight'});
title('Correct Left Trials');

%% plot intra vs. inter for each condition a given segment
segToPlot = 1;
figure;
subplot(1,2,1);
hold on;
rightRight = scatter(ones(length(outRight.netEvSameSegDist{6,6,segToPlot}),1)+...
    0.1*randn(length(outRight.netEvSameSegDist{6,6,segToPlot}),1),outRight.netEvSameSegDist{6,6,segToPlot},'r');
leftLeft = scatter(2*ones(length(outRight.netEvSameSegDist{8,8,segToPlot}),1)+...
    0.1*randn(length(outRight.netEvSameSegDist{8,8,segToPlot}),1),outRight.netEvSameSegDist{8,8,segToPlot},'b');
rightLeft = scatter(3*ones(length(outRight.netEvSameSegDist{8,6,segToPlot}),1)+...
    0.1*randn(length(outRight.netEvSameSegDist{8,6,segToPlot}),1),outRight.netEvSameSegDist{8,6,segToPlot},'g');
xlim([0 4]);
set(gca,'xtick',[1 2 3],'xticklabel',{'rightRight','leftLeft','rightLeft'});
title('Correct right trials');
subplot(1,2,2);
hold on;
rightRight = scatter(ones(length(outLeft.netEvSameSegDist{1,1,segToPlot}),1)+...
    0.1*randn(length(outLeft.netEvSameSegDist{1,1,segToPlot}),1),outLeft.netEvSameSegDist{1,1,segToPlot},'r');
leftLeft = scatter(2*ones(length(outLeft.netEvSameSegDist{3,3,segToPlot}),1)+...
    0.1*randn(length(outLeft.netEvSameSegDist{3,3,segToPlot}),1),outLeft.netEvSameSegDist{3,3,segToPlot},'b');
rightLeft = scatter(3*ones(length(outLeft.netEvSameSegDist{3,1,segToPlot}),1)+...
    0.1*randn(length(outLeft.netEvSameSegDist{3,1,segToPlot}),1),outLeft.netEvSameSegDist{3,1,segToPlot},'g');
xlim([0 4]);
set(gca,'xtick',[1 2 3],'xticklabel',{'rightRight','leftLeft','leftRight'});
title('Correct Left Trials');

%% plot histograms intra vs. inter for left trials
segToPlot = 1;
nBins = 100;
figure;
ax1=subplot(3,1,1);
hist(outLeft.netEvSameSegDist{1,1,segToPlot},nBins);
set(findobj(gca,'Type','patch'),'FaceColor','r','EdgeColor','r');
title('Left Trials, right/right');
ax2=subplot(3,1,2);
hist(outLeft.netEvSameSegDist{3,3,segToPlot},nBins);
title('Left Trials, left/left');
set(findobj(gca,'Type','patch'),'FaceColor','b','EdgeColor','b');
ax3=subplot(3,1,3);
hist(outLeft.netEvSameSegDist{3,1,segToPlot},nBins);
title('Left Trials, right/left');
set(findobj(gca,'Type','patch'),'FaceColor','g','EdgeColor','g');
suplabel('Distance','x');
suplabel('Count','y');
linkaxes([ax1 ax2 ax3],'x');

%% plot histograms intra vs. inter for right trials
segToPlot = 1;
nBins = 100;
figure;
ax1=subplot(3,1,1);
hist(outRight.netEvSameSegDist{6,6,segToPlot},nBins);
set(findobj(gca,'Type','patch'),'FaceColor','r','EdgeColor','r');
title('Right Trials, right/right');
ax2=subplot(3,1,2);
hist(outRight.netEvSameSegDist{8,8,segToPlot},nBins);
title('Right Trials, left/left');
set(findobj(gca,'Type','patch'),'FaceColor','b','EdgeColor','b');
ax3=subplot(3,1,3);
hist(outRight.netEvSameSegDist{8,6,segToPlot},nBins);
title('Right Trials, right/left');
set(findobj(gca,'Type','patch'),'FaceColor','g','EdgeColor','g');
suplabel('Distance','x');
suplabel('Count','y');
linkaxes([ax1 ax2 ax3],'x');

%% plot heatmap of distances
plotData = out;
segNum = 6;
figure;
axH = axes;
imagesc(cellfun(@nanmean,plotData.netEvSameSegDist(:,:,segNum)));
nConds = length(out.netEvConds);
set(axH,'xtick',1:nConds,'xticklabel',out.netEvConds,'ytick',1:nConds,'yticklabel',out.netEvConds);
colorbar;