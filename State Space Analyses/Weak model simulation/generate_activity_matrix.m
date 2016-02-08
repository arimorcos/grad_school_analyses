function [all_activity, trial_labels] = ...
    generate_activity_matrix(num_neurons, num_trials, choice_prob, left_neurons)


% Create matrix 
left_activity = nan(num_neurons, num_trials);
right_activity = nan(num_neurons, num_trials);
for neuron = 1:num_neurons
    temp = rand(num_trials, 1);
    correct_ind = temp <= choice_prob(neuron);
    temp(correct_ind) = left_neurons(neuron);
    temp(~correct_ind) = 1 - left_neurons(neuron);
    left_activity(neuron, :) = temp;
    
    temp = rand(num_trials, 1);
    correct_ind = temp <= choice_prob(neuron);
    temp(~correct_ind) = left_neurons(neuron);
    temp(correct_ind) = 1 - left_neurons(neuron);
    right_activity(neuron, :) = temp;
end

% Concatenate 
trial_labels = zeros(2*num_trials, 1);
trial_labels(num_trials+1:end) = 1;
all_activity = cat(2, left_activity, right_activity);