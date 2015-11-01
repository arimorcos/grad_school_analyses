function showTrialTrialClusterCorrMat(dataCell,clusterIDs,cMat,whichPoint)
%showTrialTrialClusterCorrMat.m Plots the pairwise trial-trial correlation
%matrix for every trial pair sorted by the cluster identity
%
%INPUTS
%dataCell - dataCell containing imaging data
%clusterIDs - cluster identitys
%cMat - color matrix
%whichPoint - which maze point to plot
%
%OUTPUTS
%
%ASM 10/15

%get neuronal activity
[~,trialTraces,clustCounts] = ...
    getClusteredNeuronalActivity(dataCell,clusterIDs,cMat);

%crop to relevant point 
trialTraces = trialTraces{whichPoint};
clustCounts = clustCounts{whichPoint};

%calculate correlation coefficient 
corrMat = 1 - squareform(pdist(trialTraces','correlation'));
nTrials = length(corrMat);

%% plot 
figH = figure;
axH = axes;
hold(axH,'on');

%plot matrix 
imagescnan(1:nTrials, 1:nTrials, corrMat);

%add cluster separators
cumCounts = [0; cumsum(clustCounts)];
for cluster = 1:length(cumCounts)-1

    rectH = rectangle('Position',[cumCounts(cluster) + 0.5,...
        cumCounts(cluster) + 0.5, clustCounts(cluster), clustCounts(cluster)]);
    rectH.EdgeColor = 'k';
    rectH.LineWidth = 3;
    
end

%beautify
beautifyPlot(figH, axH);

%label
axH.XLabel.String = 'Trial number';
axH.YLabel.String = axH.XLabel.String;
axH.XLim = [0.5 nTrials+0.5];
axH.YLim = [0.5 nTrials+0.5];

%add colorbar 
cBar = colorbar;
cBar.Label.String = 'Population correlation coefficient';