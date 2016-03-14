function [inter_cluster_corr, intra_cluster_corr] = ...
    getPairwiseClusterCorrelations(dataCell,clusterIDs,cMat,whichPoint)
%getPairwiseClusterCorrelations.m Calculates the pairwise trial-trial
%correlations for intra-cluster and inter-cluster
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

%split into inter and intra 
cumCounts = [0; cumsum(clustCounts)];
inter_cluster_corr = [];
intra_cluster_corr = [];
for cluster = 1:length(clustCounts);
    
    %get intra
    cluster_ind = cumCounts(cluster)+1:cumCounts(cluster+1);
    temp_intra = corrMat(cluster_ind, cluster_ind); %crop to intra
    temp_intra = temp_intra(tril(true(size(temp_intra)), -1)); %crop to off-diagonal
    intra_cluster_corr = cat(1, intra_cluster_corr, temp_intra);
    
    %get inter
    other_ind = setdiff(1:nTrials, cluster_ind);
    temp_inter = corrMat(cluster_ind, other_ind);
    inter_cluster_corr = cat(1, inter_cluster_corr, temp_inter(:));
end