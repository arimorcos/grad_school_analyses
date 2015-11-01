function plotSelectivityIndexForOverlap(dataCell, whichAct)
%plotSelectivityIndexForOverlap.m Calculates and plots the selectivity
%index for overlapping or non overlapping neurons 
%
%INPUTS
%dataCell - dataCell containing imaging data 
%whichAct - 1 x nClusters cell array of active neurons output by overlap
%   functions
%
%ASM 7/15

%% calculate
% %get nNeurons 
% nNeurons = size(dataCell{1}.imaging.dFFTraces{1},1);
% nClusters = length(whichAct);
% 
% %get selectivity index 
% selInd = getSelectivityIndex(dataCell);
% 
% %get peak selectivity index 
% peakAbsSelInd = max(abs(selInd),[],2);
% 
% %get variability coeff
% varCoeff = calculateTrialTrialVarCoefficient(dataCell);
% 
% %get full traces 
% fullTraces = cellfun(@(x) x.imaging.dFFTraces{1}, dataCell,'uniformoutput',false);
% fullTraces = cat(2,fullTraces{:});
% frameRate = 29;
% 
% %threshold and get nTransPerMin
% threshTraces = thresholdCompleteTrace(fullTraces,2.5,3);
% nTransPerMin = getNTransPerMin(threshTraces, frameRate);
% nTransPerMin = nTransPerMin{1};
% 
% %convert whichAct to nNeurons x nClusters logical
% actNeurons = zeros(nNeurons, nClusters);
% for cluster = 1:nClusters
%     actNeurons(whichAct{cluster},cluster) = 1;
% end
% 
% %define overlapping neurons 
% nActiveClusters = sum(actNeurons,2);
% nonOverlapping = nActiveClusters < 2;
% oneCluster = nActiveClusters == 1;
% overlapping = nActiveClusters > 2;
% 
% %get peak selInd for overlapping and nonOverlapping
% overlappingSelInd = peakAbsSelInd(overlapping);
% nonOverlappingSelInd = peakAbsSelInd(nonOverlapping);
% 
% %get varCoeff for overlapping and nonOverlapping
% overlappingVarCoeff = varCoeff(overlapping);
% nonOverlappingVarCoeff = varCoeff(nonOverlapping);
% 
% %get nTransPerMin for overlapping and nonOverlapping
% overlappingNTrans = nTransPerMin(overlapping);
% nonOverlappingNTrans = nTransPerMin(nonOverlapping);
% oneClusterNTrans = nTransPerMin(oneCluster);
if nargin > 1   
    out = getOverlapSelectivityInfo(dataCell, whichAct);
else
    out = dataCell;
    overlappingSelInd = out.overlappingSelInd;
    nonOverlappingSelInd = out.nonOverlappingSelInd;
    overlappingVarCoeff = out.overlappingVarCoeff;
    nonOverlappingVarCoeff = out.nonOverlappingVarCoeff;
    overlappingNTrans = out.overlappingNTrans;
    nonOverlappingNTrans = out.nonOverlappingNTrans;
    oneClusterNTrans = out.oneClusterNTrans;
    actNeurons = out.actNeurons;
end

%% plot selectivity index 
figH = figure; 
axSel = subplot(2,2,1); 
hold(axSel,'on');

%plot 
% plotH = errorbar([1 2],[mean(overlappingSelInd) mean(nonOverlappingSelInd)],...
%     [calcSEM(overlappingSelInd) calcSEM(nonOverlappingSelInd)]);
% plotH.Marker = 'o';
% plotH.Color = 'b';
% plotH.MarkerFaceColor = 'b';
% plotH.LineWidth = 2;
% plotH.LineStyle = 'none';
[barH, errH] = barwitherr([calcSEM(overlappingSelInd) calcSEM(nonOverlappingSelInd)],...
    [1 2],[mean(overlappingSelInd) mean(nonOverlappingSelInd)]);
% errH.LineWidth = 3;

%calculate stats 
[~,pVal] = ttest2(overlappingSelInd, nonOverlappingSelInd);
sigstar({[1, 2]}, pVal);

%beautify
beautifyPlot(figH, axSel);

%label
axSel.XTick = [1 2];
axSel.XTickLabel = {'Overlapping','Non-overlapping'};
axSel.XTickLabelRotation = -45;
axSel.YLabel.String = 'Peak Absolute Selectivity Index';

%% plot trial-trial-variability 
axVar = subplot(2,2,2); 
hold(axVar,'on');

%plot 
% plotH = errorbar([1 2],[mean(overlappingSelInd) mean(nonOverlappingSelInd)],...
%     [calcSEM(overlappingSelInd) calcSEM(nonOverlappingSelInd)]);
% plotH.Marker = 'o';
% plotH.Color = 'b';
% plotH.MarkerFaceColor = 'b';
% plotH.LineWidth = 2;
% plotH.LineStyle = 'none';
overlappingVarCoeff = 1 - overlappingVarCoeff;
nonOverlappingVarCoeff = 1 - nonOverlappingVarCoeff;
[barH, errH] = barwitherr([calcSEM(overlappingVarCoeff) calcSEM(nonOverlappingVarCoeff)],...
    [1 2],[mean(overlappingVarCoeff) mean(nonOverlappingVarCoeff)]);
% errH.LineWidth = 3;

%calculate stats 
[~,pVal] = ttest2(overlappingVarCoeff, nonOverlappingVarCoeff);
sigstar({[1, 2]}, pVal);

%beautify
beautifyPlot(figH, axVar);

%label
axVar.XTick = [1 2];
axVar.XTickLabel = {'Overlapping','Non-overlapping'};
axVar.XTickLabelRotation = -45;
axVar.YLabel.String = 'Pairwise trial-trial correlation';

%% plot nTransPerMin
axNTrans = subplot(2,2,3); 
hold(axNTrans,'on');

%plot 
% plotH = errorbar([1 2],[mean(overlappingSelInd) mean(nonOverlappingSelInd)],...
%     [calcSEM(overlappingSelInd) calcSEM(nonOverlappingSelInd)]);
% plotH.Marker = 'o';
% plotH.Color = 'b';
% plotH.MarkerFaceColor = 'b';
% plotH.LineWidth = 2;
% plotH.LineStyle = 'none';
[barH, errH] = barwitherr([calcSEM(overlappingNTrans) calcSEM(nonOverlappingNTrans) ...
    calcSEM(oneClusterNTrans)],1:3,[mean(overlappingNTrans) ...
    mean(nonOverlappingNTrans) mean(oneClusterNTrans)]);
% errH.LineWidth = 3;

%calculate stats 
[~,pVal(1)] = ttest2(overlappingNTrans, nonOverlappingNTrans);
[~,pVal(2)] = ttest2(oneClusterNTrans, nonOverlappingNTrans);
[~,pVal(3)] = ttest2(overlappingNTrans, oneClusterNTrans);
sigstar({[1, 2],[2, 3],[1, 3]}, pVal);

%beautify
beautifyPlot(figH, axNTrans);

%label
axNTrans.XTick = 1:3;
axNTrans.XTickLabel = {'Overlapping','Non-overlapping','One Cluster'};
axNTrans.XTickLabelRotation = -45;
axNTrans.YLabel.String = '# Transients per minute';

%% plot histogram of number of clusters
axNClusters = subplot(2,2,4); 
hold(axNClusters,'on');

%plot 
histH = histogram(sum(actNeurons,2),'Normalization','Probability');

%beautify
beautifyPlot(figH, axNClusters);

%label
axNClusters.XLim = [-0.5 max(sum(actNeurons,2))+0.5];
axNClusters.XLabel.String = '# Clusters';
axNClusters.YLabel.String = 'Fraction of cells';
