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
%get nNeurons 
nNeurons = size(dataCell{1}.imaging.dFFTraces{1},1);
nClusters = length(whichAct);

%get selectivity index 
selInd = getSelectivityIndex(dataCell);

%get peak selectivity index 
peakAbsSelInd = max(abs(selInd),[],2);

%get variability coeff
varCoeff = calculateTrialTrialVarCoefficient(dataCell);

%convert whichAct to nNeurons x nClusters logical
actNeurons = zeros(nNeurons, nClusters);
for cluster = 1:nClusters
    actNeurons(whichAct{cluster},cluster) = 1;
end

%define overlapping neurons 
nActiveClusters = sum(actNeurons,2);
nonOverlapping = nActiveClusters < 2;
overlapping = nActiveClusters > 2;

%get peak selInd for overlapping and nonOverlapping
overlappingSelInd = peakAbsSelInd(overlapping);
nonOverlappingSelInd = peakAbsSelInd(nonOverlapping);

%get varCoeff for overlapping and nonOverlapping
overlappingVarCoeff = varCoeff(overlapping);
nonOverlappingVarCoeff = varCoeff(nonOverlapping);

%% plot selectivity index 
figH = figure; 
axSel = subplot(1,2,1); 
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
errH.LineWidth = 3;

%calculate stats 
[~,pVal] = ttest2(overlappingSelInd, nonOverlappingSelInd);
sigstar({[1, 2]}, pVal);

%beautify
beautifyPlot(figH, axSel);

%label
axSel.XTick = [1 2];
axSel.XTickLabel = {'Overlapping Neurons','Non-overlapping Neurons'};
axSel.XTickLabelRotation = -45;
axSel.YLabel.String = 'Peak Absolute Selectivity Index';

%% plot trial-trial-variability 
axVar = subplot(1,2,2); 
hold(axVar,'on');

%plot 
% plotH = errorbar([1 2],[mean(overlappingSelInd) mean(nonOverlappingSelInd)],...
%     [calcSEM(overlappingSelInd) calcSEM(nonOverlappingSelInd)]);
% plotH.Marker = 'o';
% plotH.Color = 'b';
% plotH.MarkerFaceColor = 'b';
% plotH.LineWidth = 2;
% plotH.LineStyle = 'none';
[barH, errH] = barwitherr([calcSEM(overlappingVarCoeff) calcSEM(nonOverlappingVarCoeff)],...
    [1 2],[mean(overlappingVarCoeff) mean(nonOverlappingVarCoeff)]);
errH.LineWidth = 3;

%calculate stats 
[~,pVal] = ttest2(overlappingVarCoeff, nonOverlappingVarCoeff);
sigstar({[1, 2]}, pVal);

%beautify
beautifyPlot(figH, axVar);

%label
axVar.XTick = [1 2];
axVar.XTickLabel = {'Overlapping Neurons','Non-overlapping Neurons'};
axVar.XTickLabelRotation = -45;
axVar.YLabel.String = 'Trial-Trial Variability Index';
