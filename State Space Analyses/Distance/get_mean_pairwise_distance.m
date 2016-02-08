function mean_distance = get_mean_pairwise_distance(traces)
%get_mean_pairwise_distance.m Calculates the mean pairwise distance between
%trials 
%
%INPUTS
%traces - num_neurons x num_trials array 
%
%OUTPUTS
%mean_distance - scalar for the mean pairwise euclidean distance 
%
%ASM 2/16

% calculate the pairwise distance 
mean_distance = mean(pdist(traces'));