function mean_cosine_distance = get_mean_cosine_distance(traces)
%get_mean_cosine_distance.m Calculates the mean cosine distance between
%trials 
%
%INPUTS
%traces - num_neurons x num_trials array 
%
%OUTPUTS
%mean_cosine_distance - scalar for the mean pairwise cosine distance (1 - cosine similarity) 
%
%ASM 2/16

% calculate the pairwise distance 
mean_cosine_distance = mean(pdist(traces', 'cosine'));