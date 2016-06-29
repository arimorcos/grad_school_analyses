function [fracTogether, fracTrials] = ...
    calcTrialPairOverlapVsFracClustered(dataCell)
%calcTrialPairOverlapVsFracClustered.m Performs clustering on subsets of
%trials, and calculates the fraction of trials clustered together in the
%smallest case that are still clustered together in the larger cases. 
%
%INPUTS
%dataCell - dataCell containing imaging data 
%
%OUTPUTS
%fracTogether - 1 x n fractions array of fraction of trial pairs that are
%   still clustered together
%fracTrials - fraction of trials included in each of the circumstances
%
%ASM 3/16

fracTrials = [0.2, 0.4, 0.6, 0.8, 1];
which_epoch = 10;

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

traces = catBinnedDeconvTraces(dataCell);

%get nNeurons
nTrials = size(traces,3);

tracePoints = getMazePoints(traces,yPosBins,[0.5 0.75]);

%shuffle trace points 
tracePoints = tracePoints(:, :, shuffleArray(1:nTrials));
tracePoints = tracePoints(:, which_epoch, :);
nPoints = size(tracePoints, 2);

%loop through subsets 
subIDs = cell(length(fracTrials), 1);
for sub = 1:length(fracTrials)
    
    %subset 
    nKeepTrials = round(nTrials*fracTrials(sub));
    tempPoints = tracePoints(:, :, 1:nKeepTrials);
    
    clusterIDs = nan(nKeepTrials,nPoints);
    for point = 1:nPoints
        clusterIDs(:,point) = ...
            apClusterNeuronalStates(squeeze(tempPoints(:,point,:)), 10, 'nonoise');
    end
    subIDs{sub} = clusterIDs;
end

%get min keep trials 
minKeepTrials = round(min(fracTrials)*nTrials);

%enumerate list of cluster pairs in each 
sub_pairs = cell(length(fracTrials), 1);
for sub = 1:length(fracTrials)
    
    %get unique clusters 
    curr_sub = subIDs{sub}(1:minKeepTrials, :);
    unique_clusters = unique(curr_sub);
    sub_pairs{sub} = [];
    
    % loop throug h
    for cluster = 1:length(unique_clusters)
        match_trials = find(curr_sub == unique_clusters(cluster));
        trial_comb = allcomb(match_trials, match_trials);
        trial_comb = trial_comb(trial_comb(:,1) < trial_comb(:,2), :);
        sub_pairs{sub} = cat(1, sub_pairs{sub}, trial_comb);
    end
    
end

% check what fraction of the pairs match 
fracTogether = nan(1, length(fracTrials));
fracTogether(1) = 1;
for sub = 2:length(fracTrials)
    
    match_pairs = ismember(sub_pairs{sub}, sub_pairs{1}, 'rows');
    fracTogether(sub) = sum(match_pairs)/length(match_pairs);
    
end

