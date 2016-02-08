function mean_variance = get_mean_variance(traces)
%get_mean_variance.m Calculates the mean variance across neurons 
%
%INPUTS
%traces - num_neurons x num_trials array 
%
%OUTPUTS
%mean_variance - scalar for the mean variance 
%
%ASM 2/16

% take the standard deviation across each neuron 
neuron_std = nanstd(traces, 0, 2);
 
% square to get variance 
neuron_var = neuron_std.^2;

% take mean 
mean_variance = mean(neuron_var);