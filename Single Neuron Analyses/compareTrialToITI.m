function out = compareTrialToITI(dataCell)
%compareTrialToITI.m Calculates the mean activity during each trial and
%the mean activity during the iti and performs statistics
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%out - structure containing: 
%   p_vals - num_cells x 1 array of p_vals from one-tailed t-test
%   mean_trial - num_cells x num_trials array of mean deconv activity
%       during trial
%   mean_iti - num_cells x num_trials array of mean deconv activity
%       during iti
%
%ASM 6/16

%filter 
dataCell = filterROIGroups(dataCell, 1);

% get deconv trace 
deconv_trace = dataCell{1}.imaging.filterDeconvTrace; 

%get unique trials 
unique_trials = unique(dataCell{1}.imaging.trialIDs(1,...
    logical(dataCell{1}.imaging.trialIDs(2,:))));
num_trials = length(unique_trials);

% get num_neurons 
num_neurons = size(deconv_trace, 1);

%initialize 
out.p_vals = nan(num_neurons, 1);
out.mean_trial = nan(num_neurons, num_trials);
out.mean_iti = nan(num_neurons, num_trials);

trial_ids_diff = diff(dataCell{1}.imaging.trialIDs(1,:));

% loop through 
for trial_ind = 1:num_trials
    
    % get trial_frames corresponding to trial
    trial_frames = dataCell{1}.imaging.trialIDs(1,:) == unique_trials(trial_ind);
    
    % get iti_frames corresponding to iti immediately following trials 
    iti_start = find(trial_ids_diff == -unique_trials(trial_ind)) + 1;
    iti_end = find(trial_ids_diff == 1 + unique_trials(trial_ind));
    iti_frames = iti_start:iti_end;
    
    % take mean of trial 
    out.mean_trial(:, trial_ind) = nanmean(deconv_trace(:, trial_frames), 2);
    out.mean_iti(:, trial_ind) = nanmean(deconv_trace(:, iti_frames), 2);
   
end

for neuron = 1:num_neurons
    [~, out.p_vals(neuron)] = ttest2(out.mean_trial(neuron, :), ...
        out.mean_iti(neuron,:), 'Tail', 'right');
end