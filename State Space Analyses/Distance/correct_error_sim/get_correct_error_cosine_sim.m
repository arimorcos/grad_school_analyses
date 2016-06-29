function out = get_correct_error_cosine_sim(dataCell, use_correlation)
%get_correct_error_cosine_sim.m Calculates the cosine similarity at each
%bin between a given test trial and correct and incorrect left 6-0 and
%right 0-6 trials.
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPTUS
%out - structure containing:
%
%ASM 3/16

if nargin < 2 || isempty(use_correlation)
    use_correlation = true;
end

%get traces
traces = catBinnedDeconvTraces(dataCell);

%get trial filters
correct_left_60_ind = findTrials(dataCell, 'result.correct==1;maze.numLeft==6');
error_left_60_ind = findTrials(dataCell, 'result.correct==0;maze.numLeft==6');
correct_right_06_ind = findTrials(dataCell, 'result.correct==1;maze.numLeft==0');
error_right_06_ind = findTrials(dataCell, 'result.correct==0;maze.numLeft==0');

%filter traces
correct_left_60_traces = traces(:, :, correct_left_60_ind);
error_left_60_traces = traces(:, :, error_left_60_ind);
correct_right_06_traces = traces(:, :, correct_right_06_ind);
error_right_06_traces = traces(:, :, error_right_06_ind);

%  get num bins
num_bins = size(traces, 2);

% %initialize
% correct_left_60_sim = nan(num_trials, num_bins);
% error_left_60_sim = nan(num_trials, num_bins);
% correct_right_06_sim = nan(num_trials, num_bins);
% error_right_06_sim = nan(num_trials, num_bins);
%
% % loop through each trial and calculate similarities
% for trial = 1:num_trials
%
%     %pull out
%
% end

correct_left_intra_mean = nan(num_bins, 1);
correct_right_intra_mean = nan(num_bins, 1);
error_left_intra_mean = nan(num_bins, 1);
error_right_intra_mean = nan(num_bins, 1);
correct_left_correct_right_mean = nan(num_bins, 1);
correct_left_error_left_mean = nan(num_bins, 1);
correct_left_error_right_mean = nan(num_bins, 1);
correct_right_error_right_mean = nan(num_bins, 1);
correct_right_error_left_mean = nan(num_bins, 1);
error_left_error_right_mean = nan(num_bins, 1);

correct_left_intra_sem = nan(num_bins, 1);
correct_right_intra_sem = nan(num_bins, 1);
error_left_intra_sem = nan(num_bins, 1);
error_right_intra_sem = nan(num_bins, 1);
correct_left_correct_right_sem = nan(num_bins, 1);
correct_left_error_left_sem = nan(num_bins, 1);
correct_left_error_right_sem = nan(num_bins, 1);
correct_right_error_right_sem = nan(num_bins, 1);
correct_right_error_left_sem = nan(num_bins, 1);
error_left_error_right_sem = nan(num_bins, 1);

if use_correlation
    which_measure = 'correlation';
else
    which_measure = 'cosine';
end

for use_bin = 1:num_bins
    
    temp_intra = 1 - pdist(squeeze(...
        correct_left_60_traces(:, use_bin, :))', which_measure);
    correct_left_intra_mean(use_bin) = nanmean(temp_intra);
    correct_left_intra_sem(use_bin) = calcSEM(temp_intra');
    
    temp_intra = 1 - pdist(squeeze(...
        correct_right_06_traces(:, use_bin, :))', which_measure);
    correct_right_intra_mean(use_bin) = nanmean(temp_intra);
    correct_right_intra_sem(use_bin) = calcSEM(temp_intra');
    
    temp_intra = 1 - pdist(squeeze(...
        error_left_60_traces(:, use_bin, :))', which_measure);
    error_left_intra_mean(use_bin) = nanmean(temp_intra);
    error_left_intra_sem(use_bin) = calcSEM(temp_intra');
    
    temp_intra = 1 - pdist(squeeze(...
        error_right_06_traces(:, use_bin, :))', which_measure);
    error_right_intra_mean(use_bin) = nanmean(temp_intra);
    error_right_intra_sem(use_bin) = calcSEM(temp_intra');
    
    [correct_left_correct_right_mean(use_bin), ...
        correct_left_correct_right_sem(use_bin)] = ...
        get_collapsed_cosine_sim(...
        correct_left_60_traces, correct_right_06_traces, use_bin, which_measure);
    
    [correct_left_error_left_mean(use_bin),...
        correct_left_error_left_sem(use_bin)] = ...
        get_collapsed_cosine_sim(...
        correct_left_60_traces, error_left_60_traces, use_bin, which_measure);
    
    [correct_left_error_right_mean(use_bin), ...
        correct_left_error_right_sem(use_bin)] = ...
        get_collapsed_cosine_sim(...
        correct_left_60_traces, error_right_06_traces, use_bin, which_measure);
    
    [correct_right_error_right_mean(use_bin),...
        correct_right_error_right_sem(use_bin)] = ...
        get_collapsed_cosine_sim(...
        correct_right_06_traces, error_right_06_traces, use_bin, which_measure);
    
    [correct_right_error_left_mean(use_bin),...
        correct_right_error_left_sem(use_bin)] = ...
        get_collapsed_cosine_sim(...
        correct_right_06_traces, error_left_60_traces, use_bin, which_measure);
    
    [error_left_error_right_mean(use_bin),...
        error_left_error_right_sem(use_bin)] = ...
        get_collapsed_cosine_sim(...
        error_left_60_traces, error_right_06_traces, use_bin, which_measure);
    
end

out.correct_left_intra.mean = correct_left_intra_mean;
out.correct_right_intra.mean = correct_right_intra_mean;
out.error_left_intra.mean = error_left_intra_mean;
out.error_right_intra.mean = error_right_intra_mean;
out.correct_left_correct_right.mean = correct_left_correct_right_mean;
out.correct_left_error_left.mean = correct_left_error_left_mean;
out.correct_left_error_right.mean = correct_left_error_right_mean;
out.correct_right_error_right.mean = correct_right_error_right_mean;
out.correct_right_error_left.mean = correct_right_error_left_mean;
out.error_left_error_right.mean = error_left_error_right_mean;

out.correct_left_intra.sem = correct_left_intra_sem;
out.correct_right_intra.sem = correct_right_intra_sem;
out.error_left_intra.sem = error_left_intra_sem;
out.error_right_intra.sem = error_right_intra_sem;
out.correct_left_correct_right.sem = correct_left_correct_right_sem;
out.correct_left_error_left.sem = correct_left_error_left_sem;
out.correct_left_error_right.sem = correct_left_error_right_sem;
out.correct_right_error_right.sem = correct_right_error_right_sem;
out.correct_right_error_left.sem = correct_right_error_left_sem;
out.error_left_error_right.sem = error_left_error_right_sem;

out.use_correlation = use_correlation;
out.yPosBins = dataCell{1}.imaging.yPosBins;

end

function [mean_sim, sem_sim] = ...
    get_collapsed_cosine_sim(traces_1, traces_2, use_bin, which_measure)

cos_dist = pdist2(...
    squeeze(traces_1(:, use_bin, :))',...
    squeeze(traces_2(:, use_bin, :))', which_measure);
all_sim = 1 - reshape(cos_dist, 1, []);
mean_sim = nanmean(all_sim);
sem_sim = calcSEM(all_sim');
end