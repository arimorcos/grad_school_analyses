function plotDeltaPointBehavior(varargin)
%plotDeltaPointBehavior.m Plots whether the distributions are significantly
%different at each delta point 
%
%INPUTS
%deltaPointNeurons - deltaPoint structure with bootstrapping created by
%   quanitfyInternalVariability for neurons
%deltaPointNeurons - deltaPoint structure with bootstrapping created by
%   quanitfyInternalVariability for behavior 
%
%OR 
%
%dataCell - dataCell from which to generate data
%
%ASM 4/15

%% process inputs
if length(varargin) == 3 
    deltaPointNeuron = varargin{1};
    deltaPointBehavior = varargin{2};
    deltaPointBehavNeur = varargin{3};
elseif length(varargin) == 1 && iscell(varargin{1})
    [~,~,deltaPointNeuron] = quantifyInternalVariability(dataCell,...
        'usebootstrapping',true);
    [~,~,deltaPointBehavior] = quantifyInternalVariability(dataCell,...
        'usebootstrapping',true,'useBehavior',true);
    [~,~,deltaPointBehavNeur] = quantifyBehavToNeuronalClusterProb(dataCell,...
        'usebootstrapping',true);
else
    error('Cannot interpret inputs');
end

%% calculate statistics

%get nDelta 
nDelta = size(deltaPointNeuron.nSTDAboveMedian,1);

%get nPoints
nPoints = nDelta + 1;

%loop through 
pVal = nan(nDelta,3);
sig = nan(nDelta,3);
diffs = deltaPointNeuron.diffs;
for delta = 1:nDelta
    
%     %get distance matrix
%     pointDist = triu(squareform(pdist([1:nPoints]')));
%     
%     %get matchInd
%     matchInd = pointDist == delta;
%     
%     %get matching val
%     behav = deltaPointBehavior.fullMat.nSTDAboveMedian(matchInd);
%     neur = deltaPointNeuron.fullMat.nSTDAboveMedian(matchInd);
%     behNeur = deltaPointBehavNeur.fullMat.nSTDAboveMedian(matchInd);
%     
%     %get pvals 
%     [~,pVal(delta,1)] = ttest2(neur,behav);
%     [~,pVal(delta,2)] = ttest2(neur,behNeur);
%     [~,pVal(delta,3)] = ttest2(behav,behNeur);

      %get actual diffs 
      neur_Behav_diff = deltaPointNeuron.totalNSTDAboveMedian(delta) - ...
          deltaPointBehavior.totalNSTDAboveMedian(delta);
      behav_BehavNeur_diff = deltaPointBehavNeur.totalNSTDAboveMedian(delta) - ...
          deltaPointBehavior.totalNSTDAboveMedian(delta);
      neur_BehavNeur_diff = deltaPointNeuron.totalNSTDAboveMedian(delta) - ...
          deltaPointBehavNeur.totalNSTDAboveMedian(delta);
      
      %get percentiles and store for behav_neur
      neur_behav_p999 = prctile(diffs.neur_Behav_Diff(delta,:),[0.05 99.95]);
      neur_behav_p99 = prctile(diffs.neur_Behav_Diff(delta,:),[0.5 99.5]);
      neur_behav_p95 = prctile(diffs.neur_Behav_Diff(delta,:),[2.5 97.5]);
      if neur_Behav_diff >= neur_behav_p999
          sig(delta,1) = 3;
      elseif neur_Behav_diff >= neur_behav_p99
          sig(delta,1) = 2;
      elseif neur_Behav_diff >= neur_behav_p95
          sig(delta,1) = 1;
      end
      
      %get percentiles and store for behav_neur
      neur_BehavNeur_p999 = prctile(diffs.neur_BehavNeur_Diff(delta,:),[0.05 99.95]);
      neur_BehavNeur_p99 = prctile(diffs.neur_BehavNeur_Diff(delta,:),[0.5 99.5]);
      neur_BehavNeur_p95 = prctile(diffs.neur_BehavNeur_Diff(delta,:),[2.5 97.5]);
      if neur_BehavNeur_diff >= neur_BehavNeur_p999
          sig(delta,2) = 3;
      elseif neur_BehavNeur_diff >= neur_BehavNeur_p99
          sig(delta,2) = 2;
      elseif neur_BehavNeur_diff >= neur_BehavNeur_p95
          sig(delta,2) = 1;
      end
      
      %get percentiles and store for behav_neur
      behav_BehavNeur_p999 = prctile(diffs.behav_BehavNeur_Diff(delta,:),[0.05 99.95]);
      behav_BehavNeur_p99 = prctile(diffs.behav_BehavNeur_Diff(delta,:),[0.5 99.5]);
      behav_BehavNeur_p95 = prctile(diffs.behav_BehavNeur_Diff(delta,:),[2.5 97.5]);
      if behav_BehavNeur_diff >= behav_BehavNeur_p999
          sig(delta,3) = 3;
      elseif behav_BehavNeur_diff >= behav_BehavNeur_p99
          sig(delta,3) = 2;
      elseif behav_BehavNeur_diff >= behav_BehavNeur_p95
          sig(delta,3) = 1;
      end
      
        
%     [~,pVal(delta,1)] = ttest2(deltaPointNeuron.allNSTDAboveMedian(delta,:),...
%         deltaPointBehavior.allNSTDAboveMedian(delta,:));
%     [~,pVal(delta,2)] = ttest2(deltaPointNeuron.allNSTDAboveMedian(delta,:),...
%         deltaPointBehavNeur.allNSTDAboveMedian(delta+1,:));
%     [~,pVal(delta,3)] = ttest2(deltaPointBehavNeur.allNSTDAboveMedian(delta+1,:),...
%         deltaPointBehavior.allNSTDAboveMedian(delta,:));
end

%% plot 
figH = figure;
axH = axes;
hold(axH,'on');

% useField = 'nSTDAboveMedian';
useField = 'totalNSTDAboveMedian';

%plot points 
meanNeuron = mean(deltaPointNeuron.(useField),2);
meanBehavior = mean(deltaPointBehavior.(useField),2);
meanBehaviorNeuron = mean(deltaPointBehavNeur.(useField),2);
plotNeuron = plot(1:nDelta,meanNeuron);
plotBehavior = plot(1:nDelta,meanBehavior);
plotBehavNeur = plot(0:nDelta,meanBehaviorNeuron);

%set attributes
colors = distinguishable_colors(size(pVal,2));
plotNeuron.Color = colors(1,:);
plotNeuron.LineWidth = 2;
plotNeuron.Marker = 'o';
plotNeuron.MarkerSize = 13;
plotNeuron.MarkerFaceColor = colors(1,:);

plotBehavior.Color = colors(2,:);
plotBehavior.LineWidth = 2;
plotBehavior.Marker = '^';
plotBehavior.MarkerSize = 13;
plotBehavior.MarkerFaceColor = colors(2,:);

plotBehavNeur.Color = colors(3,:);
plotBehavNeur.LineWidth = 2;
plotBehavNeur.Marker = 'd';
plotBehavNeur.MarkerSize = 13;
plotBehavNeur.MarkerFaceColor = colors(3,:);

%Add statistics 
limRange = range(axH.YLim);
axH.YLim(2) = axH.YLim(2) + 0.1*limRange;
colors = 'mck';
for delta = 1:nDelta
    allVals = cat(2,meanNeuron(delta),meanBehavior(delta),meanBehaviorNeuron(delta));
    for compInd = 1:size(pVal,2)
%         if pVal(delta,compInd) <= 0.001 
        if sig(delta,compInd) == 3 
            textH = text(delta,max(allVals) +...
                compInd*0.02*limRange,'***');
%         elseif pVal(delta,compInd) <= 0.01
        elseif sig(delta,compInd) == 2
            textH = text(delta,max(allVals) +...
                compInd*0.02*limRange,'**');
%         elseif pVal(delta,compInd) <= 0.05
        elseif sig(delta,compInd) == 1
            textH = text(delta,max(allVals) +...
                compInd*0.02*limRange,'*');
        else
            continue;
        end
        textH.HorizontalAlignment = 'Center';
        textH.VerticalAlignment = 'Middle';
        textH.FontSize = 30;
        textH.Color = colors(compInd);
    end
end

%set axis 
axis(axH,'square');
axH.FontSize = 20;
axH.LabelFontSizeMultiplier = 1.5;
axH.XLabel.String = '\Delta Maze Epochs';
axH.YLabel.String = '# Standard Deviations Above Shuffle Median';

%legend
legend([plotNeuron,plotBehavior,plotBehavNeur],{'Clustering based on neuronal data',...
    'Clustering based on behavioral data','Predict neuronal clusters based on behavioral clusters'},'Location','NorthEast');
