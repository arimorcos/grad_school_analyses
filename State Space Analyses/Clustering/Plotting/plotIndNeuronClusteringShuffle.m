function plotIndNeuronClusteringShuffle(out)

figH = figure;

nShuffles = size(out.shuffleCluster.clusterR2,2);

%% plot cluster vs shuffle cluster
axClusterShuffle = subplot(2,2,1);
hold(axClusterShuffle,'on');

%get percentile for each 
sortedShuffle = sort(out.shuffleCluster.clusterR2,2);

%find first greater than 
fracGreaterClusterR2ClusterShuffle = nan(length(out.clusterR2),1);
for neuron = 1:length(out.clusterR2)
    firstGreater = find(out.clusterR2(neuron) >= sortedShuffle(neuron,:),1,'last');
    if ~isempty(firstGreater)
        fracGreaterClusterR2ClusterShuffle(neuron) = firstGreater/nShuffles;    
    else
        fracGreaterClusterR2ClusterShuffle(neuron) = 0;
    end
end

%find first greater than for shuffle 
fracGreaterShuffle = nan(length(out.clusterR2),1);
sortedShuffleShuffle = sort(out.shuffleCluster.clusterR2(:,2:end),2);
for neuron = 1:length(out.clusterR2)
    firstGreater = find(out.shuffleCluster.clusterR2(neuron,1) >= sortedShuffleShuffle(neuron,:),1,'last');
    if ~isempty(firstGreater)
        fracGreaterShuffle(neuron) = firstGreater/nShuffles;    
    else
        fracGreaterShuffle(neuron) = 0;
    end
end

%histogram of fracGreater 
histReal = histoutline(1-fracGreaterClusterR2ClusterShuffle,50,false,'Normalization','Probability');

%histogram of fracGreater for shuffle
histShuffle = histoutline(1-fracGreaterShuffle,50,false,'Normalization','Probability');

uistack(histReal,'top');
histReal.LineWidth = 2;
histShuffle.LineWidth = 2;
histShuffle.Color = [0.7 0.7 0.7];

%beautify 
beautifyPlot(figH,axClusterShuffle);

%label 
axClusterShuffle.XLabel.String = 'P Value';
axClusterShuffle.YLabel.String = 'Fraction of Neurons';
axClusterShuffle.Title.String = 'Cluster R^{2} vs. Shuffled Cluster Labels';

%% plot turn vs shuffle turn
axTurnShuffle = subplot(2,2,2);
hold(axTurnShuffle, 'on');

%get percentile for each 
sortedShuffle = sort(out.shuffleTurn.turnR2,2);

%find first greater than 
fracGreaterTurnR2TurnShuffle = nan(length(out.turnR2),1);
for neuron = 1:length(out.turnR2)
    firstGreater = find(out.turnR2(neuron) >= sortedShuffle(neuron,:),1,'last');
    if ~isempty(firstGreater)
        fracGreaterTurnR2TurnShuffle(neuron) = firstGreater/nShuffles;    
    else
        fracGreaterTurnR2TurnShuffle(neuron) = 0;
    end
end

%find first greater than for shuffle 
fracGreaterShuffle = nan(length(out.turnR2),1);
sortedShuffleShuffle = sort(out.shuffleTurn.turnR2(:,2:end),2);
for neuron = 1:length(out.clusterR2)
    firstGreater = find(out.shuffleTurn.turnR2(neuron,1) >= sortedShuffleShuffle(neuron,:),1,'last');
    if ~isempty(firstGreater)
        fracGreaterShuffle(neuron) = firstGreater/nShuffles;    
    else
        fracGreaterShuffle(neuron) = 0;
    end
end

%histogram of fracGreater 
histReal = histogram(1-fracGreaterTurnR2TurnShuffle,50);

%histogram of fracGreater for shuffle
histShuffle = histogram(1-fracGreaterShuffle,50);

%beautify 
beautifyPlot(figH,axTurnShuffle);

%label 
axTurnShuffle.XLabel.String = 'P Value';
axTurnShuffle.YLabel.String = 'Neuron count';
axTurnShuffle.Title.String = 'Turn R^{2} vs. Shuffled Turn Labels';

%% plot cluster vs shuffle both
axClusterBoth = subplot(2,2,3);
hold(axClusterBoth, 'on');

%get percentile for each 
sortedShuffle = sort(out.shuffleBoth.clusterR2,2);

%find first greater than 
fracGreater = nan(length(out.clusterR2),1);
for neuron = 1:length(out.clusterR2)
    firstGreater = find(out.clusterR2(neuron) >= sortedShuffle(neuron,:),1,'last');
    if ~isempty(firstGreater)
        fracGreater(neuron) = firstGreater/nShuffles;    
    else
        fracGreater(neuron) = 0;
    end
end

%find first greater than for shuffle 
fracGreaterShuffle = nan(length(out.clusterR2),1);
sortedShuffleShuffle = sort(out.shuffleBoth.clusterR2(:,2:end),2);
for neuron = 1:length(out.clusterR2)
    firstGreater = find(out.shuffleBoth.clusterR2(neuron,1) >= sortedShuffleShuffle(neuron,:),1,'last');
    if ~isempty(firstGreater)
        fracGreaterShuffle(neuron) = firstGreater/nShuffles;    
    else
        fracGreaterShuffle(neuron) = 0;
    end
end

%histogram of fracGreater 
histReal = histogram(1-fracGreater,50);

%histogram of fracGreater for shuffle
histShuffle = histogram(1-fracGreaterShuffle,50);

%beautify 
beautifyPlot(figH,axClusterBoth);

%label 
axClusterBoth.XLabel.String = 'P Value';
axClusterBoth.YLabel.String = 'Neuron count';
axClusterBoth.Title.String = 'Cluster R^{2} vs. Shuffled Turn Labels & Shuffled Cluster Labels';
axClusterBoth.Title.FontSize = 20;

%% plot turn vs shuffle both
axTurnBoth = subplot(2,2,4);
hold(axTurnBoth, 'on');

%get percentile for each 
sortedShuffle = sort(out.shuffleBoth.turnR2,2);

%find first greater than 
fracGreater = nan(length(out.turnR2),1);
for neuron = 1:length(out.turnR2)
    firstGreater = find(out.turnR2(neuron) >= sortedShuffle(neuron,:),1,'last');
    if ~isempty(firstGreater)
        fracGreater(neuron) = firstGreater/nShuffles;    
    else
        fracGreater(neuron) = 0;
    end
end

%find first greater than for shuffle 
fracGreaterShuffle = nan(length(out.turnR2),1);
sortedShuffleShuffle = sort(out.shuffleBoth.turnR2(:,2:end),2);
for neuron = 1:length(out.turnR2)
    firstGreater = find(out.shuffleBoth.turnR2(neuron,1) >= sortedShuffleShuffle(neuron,:),1,'last');
    if ~isempty(firstGreater)
        fracGreaterShuffle(neuron) = firstGreater/nShuffles;    
    else
        fracGreaterShuffle(neuron) = 0;
    end
end

%histogram of fracGreater 
histReal = histogram(1-fracGreater,50);

%histogram of fracGreater for shuffle
histShuffle = histogram(1-fracGreaterShuffle,50);

%beautify 
beautifyPlot(figH,axTurnBoth);

%label 
axTurnBoth.XLabel.String = 'P Value';
axTurnBoth.YLabel.String = 'Neuron count';
axTurnBoth.Title.String = 'Turn R^{2} vs. Shuffled Turn Labels & Shuffled Cluster Labels';
axTurnBoth.Title.FontSize = 20;


%add legend 
legend([histReal, histShuffle], {'Actual Distribution','Shuffled Distribution'},...
    'Location','NorthEast');

%% plot clusterR2 pValue vs. turnR2 pValue  

%create new figure 
handles.fig2 = figure;
handles.scatAx = axes;

%scatter 
scatH = scatter(1 - fracGreaterClusterR2ClusterShuffle, 1 - fracGreaterTurnR2TurnShuffle);

%beautify 
beautifyPlot(handles.fig2, handles.scatAx);

%label 
handles.scatAx.YLabel.String = 'Turn R^{2} P Value';
handles.scatAx.XLabel.String = 'Cluster R^{2} P Value';

%add text 
[r,p] = corrcoef(1 - fracGreaterClusterR2ClusterShuffle, 1 - fracGreaterTurnR2TurnShuffle);
textH = text(0.02,0.98,sprintf('r = %.2f, p = %.2f',r(1,2),p(1,2)));
textH.VerticalAlignment = 'top';
textH.HorizontalAlignment = 'Left';
textH.FontSize = 20;

%add unity line 
equalAxes(handles.scatAx,true);
%% plot clusters 
% axClust = subplot(2,3,1);
% 
% scatH = scatter(reshape(repmat(out.clusterR2,1,nShuffles),[],1),out.clusterShuffleR2(:));
% 
% %beautify
% beautifyPlot(figH,axClust);
% 
% %label 
% axClust.XLabel.String = 'Real Cluster R^{2}';
% axClust.YLabel.String = 'Shuffled Cluster R^{2}';
% equalAxes(axClust,true);
% 
% %% plot turn 
% axTurn = subplot(2,3,2);
% 
% % scatH = scatter(out.turnR2,shuffleOut.turnR2);
% scatH = scatter(reshape(repmat(out.turnR2,1,nShuffles),[],1),out.turnShuffleR2(:));
% 
% %beautify
% beautifyPlot(figH,axTurn);
% 
% %label 
% axTurn.XLabel.String = 'Real Turn R^{2}';
% axTurn.YLabel.String = 'Shuffled Turn R^{2}';
% equalAxes(axTurn,true);
% 
% %% plot cluster vs. total 
% 
% axClustTotal = subplot(2,3,3);
% hold(axClustTotal,'on');
% 
% scatReal = scatter(out.clusterR2,out.totalR2,'b');
% scatShuffle = scatter(out.clusterShuffleR2(:),out.totalShuffleR2(:),'r');
% 
% %beautify
% beautifyPlot(figH,axClustTotal);
% 
% %label 
% axClustTotal.XLabel.String = 'Cluster R^{2}';
% axClustTotal.YLabel.String = 'Total R^{2}';
% 
% %legend 
% legend([scatReal scatShuffle],{'Real','Shuffled'},'Location','NorthWest');
% equalAxes(axClustTotal,true);

% %% plot turn vs total
% 
% axTurnTotal = subplot(2,3,4);
% hold(axTurnTotal,'on');
% 
% scatReal = scatter(out.turnR2,out.totalR2,'b');
% scatShuffle = scatter(shuffleOut.turnR2,shuffleOut.totalR2,'r');
% 
% %beautify
% beautifyPlot(figH,axTurnTotal);
% 
% %label 
% axTurnTotal.XLabel.String = 'Turn R^{2}';
% axTurnTotal.YLabel.String = 'Total R^{2}';
% 
% %legend 
% legend([scatReal scatShuffle],{'Real','Shuffled'},'Location','SouthEast');
% equalAxes(axTurnTotal,true);
% 
% %% plot cluster vs turn
% 
% axTurnCluster = subplot(2,3,5);
% hold(axTurnCluster,'on');
% 
% scatReal = scatter(out.turnR2,out.clusterR2,'b');
% scatShuffle = scatter(shuffleOut.turnR2,shuffleOut.clusterR2,'r');
% 
% %beautify
% beautifyPlot(figH,axTurnCluster);
% 
% %label 
% axTurnCluster.XLabel.String = 'Turn R^{2}';
% axTurnCluster.YLabel.String = 'Cluster R^{2}';
% 
% %legend 
% legend([scatReal scatShuffle],{'Real','Shuffled'},'Location','SouthEast');
% equalAxes(axTurnCluster,true);

%% plot cluster vs turn

% axTurnCluster = subplot(1,2,1);
% hold(axTurnCluster,'on');
% 
% scatShuffle = scatter(out.turnShuffleR2(:),out.clusterShuffleR2(:),'r');
% scatReal = scatter(out.turnR2,out.clusterR2,'b');
% 
% %beautify
% beautifyPlot(figH,axTurnCluster);
% 
% %label 
% axTurnCluster.XLabel.String = 'Turn R^{2}';
% axTurnCluster.YLabel.String = 'Cluster R^{2}';
% 
% %legend 
% legend([scatReal scatShuffle],{'Real','Shuffled'},'Location','NorthEast');
% equalAxes(axTurnCluster,true);
