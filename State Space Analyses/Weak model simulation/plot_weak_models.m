function plot_weak_models(neuron_range, choice_prob, num_trials, mode)
%plot_weak_models.m Simulates weak models for various numbers of neurons
%with a given choice probability and plots
%
%INPUTS
%neuron_range - indices of numbers of neurons to try
%choice_prob - choice probability (can be a vector to display multiple
%   probs)
%num_trials - number of trials to simulate
%mode - modelspec
%
%ASM 1/16

num_runs = length(neuron_range);
num_choice_probs = length(choice_prob);
leg_ent = cell(num_choice_probs, 1);
accuracy = nan(num_choice_probs, num_runs);


for prob = 1:num_choice_probs
    parfor run = 1:num_runs
        accuracy(prob, run) = simulate_weak_models(neuron_range(run), ...
            choice_prob(prob), num_trials, mode);
        
    end
    dispProgress('Prob %d/%d', prob, prob, num_choice_probs);
    leg_ent{prob} = sprintf('%.2f', choice_prob(prob));
end

% plot
figH = figure;
axH = axes;

% plot
plot(neuron_range, accuracy);

%beautify
beautifyPlot(figH, axH);

%lim
axH.YLim = [0, 1];

%label
axH.XLabel.String = 'Number of neurons';
axH.YLabel.String = 'Prediction accuracy';
axH.Title.String = mode;
legend(leg_ent, 'Location', 'SouthEast');