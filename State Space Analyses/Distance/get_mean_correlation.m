function mean_correlation = get_mean_correlation(traces)
%get_mean_cosine_distance.m Calculates the mean correlation between
%trials 
%
%INPUTS
%traces - num_neurons x num_trials array 
%
%OUTPUTS
%mean_correlation- scalar for the mean pairwise correlation
%
%ASM 2/16

% calculate the pairwise distance 
mean_correlation = mean(1 - pdist(traces', 'correlation'));