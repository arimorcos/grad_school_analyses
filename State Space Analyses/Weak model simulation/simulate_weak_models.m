function accuracy = simulate_weak_models(num_neurons, choice_prob, num_trials,...
    mode)
%simulate_weak_models.m Simulates the averaging of weak models to make a
%prediction 
%
%INPUTS
%num_neurons - number of neurons to include
%choice_prob - choice probability for each neuron. Can either be a scalar,
%   in which case the same value will be used for every neuron, or a vector
%   with length equal to number of neurons 
%num_trials - number of trials to use
%mode - mode for the linear regression
%
%OUTPUTS
%
%ASM 1/16

% Error check 
if length(choice_prob) > 1
    assert(num_neurons == length(choice_prob), ...
        'Number of neurons must match length of choice probability vector.');
else
    choice_prob = repmat(choice_prob, num_neurons, 1);
end

assert(all(choice_prob <= 1), 'Choice probability cannot be greater than 1.');
assert(all(choice_prob >= 0), 'Choice probability cannot be less than 0.');

% set up left and right neurons 
left_neurons = randi([0, 1], num_neurons, 1);

% generate train matrix and test matrix 
[all_activity_train, trial_labels_train] = ...
    generate_activity_matrix(num_neurons, num_trials, choice_prob, left_neurons);
[all_activity_test, trial_labels_test] = ...
    generate_activity_matrix(num_neurons, num_trials, choice_prob, left_neurons);


% % fit linear regression 
% mdl = fitlm(all_activity_train', trial_labels_train, mode);

% fit lda
mdl = fitcdiscr(all_activity_train', trial_labels_train, 'DiscrimType', mode);

% predict test data 
% y_hat = round(mdl.predict(all_activity_test'));
y_hat = mdl.predict(all_activity_test');

% Calculate accuracy 
accuracy = sum(trial_labels_test == y_hat)/length(y_hat);

