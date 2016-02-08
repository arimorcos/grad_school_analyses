function out = getClusteredDimensionality(dataCell, trial_filter)
%getClusteredDimensionality.m Do the one clustering and calculate the
%fraction of the space explored at each epoch. 
%
%INPUTS
%dataCell - dataCell containing imaging data 
%
%OUTPUTS
%out -structure containing the following
%   totalClusters - number of total clusters 
%   clusterIDs - array of the clusters occupied at each time point 
%
%ASM 1/16

if nargin < 2 
    trial_filter = 3;
end

%cluster
[~,~,clusterIDs,~] = getClusteredMarkovMatrix(dataCell, ...
    'oneclustering', true);

%get unique clusters 
num_unique = length(unique(clusterIDs(:)));

%get unique clusters at each time point 
num_unique_each_point = nan(10, 1);
unique_count = cell(10, 1);
for point = 1:10
    [unique_clusters, unique_count{point}] = count_unique(clusterIDs(:, point));
    num_unique_each_point(point) = sum(unique_count{point} >= trial_filter);
end

% fraction 
out.total_clusters = num_unique;
out.clusterIDs = clusterIDs;
out.frac_explored = num_unique_each_point./num_unique;