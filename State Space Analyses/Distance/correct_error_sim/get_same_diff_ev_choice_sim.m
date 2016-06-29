function out = get_same_diff_ev_choice_sim(dataCell, use_correlation)
%get_same_diff_ev_choice_sim.m Calculates the cosine similarity at each
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

same_ev_same_choice_mean = nan(num_bins, 1);
same_ev_diff_choice_mean = nan(num_bins, 1);
diff_ev_same_choice_mean = nan(num_bins, 1);
diff_ev_diff_choice_mean = nan(num_bins, 1);

same_ev_same_choice_sem = nan(num_bins, 1);
same_ev_diff_choice_sem = nan(num_bins, 1);
diff_ev_same_choice_sem = nan(num_bins, 1);
diff_ev_diff_choice_sem = nan(num_bins, 1);

if use_correlation
    which_measure = 'correlation';
else
    which_measure = 'cosine';
end

for use_bin = 1:num_bins
    
    %same choice same ev
    temp_same_choice_same_ev_left = 1 - pdist(squeeze(...
        correct_left_60_traces(:, use_bin, :))', which_measure);
    temp_same_choice_same_ev_right = 1 - pdist(squeeze(...
        correct_right_06_traces(:, use_bin, :))', which_measure);
    temp_same_choice_same_ev = cat(2, temp_same_choice_same_ev_left,...
        temp_same_choice_same_ev_right);
    same_ev_same_choice_mean(use_bin) = nanmean(temp_same_choice_same_ev);
    same_ev_same_choice_sem(use_bin) = calcSEM(temp_same_choice_same_ev');
    
    %same choice diff ev
    temp_same_choice_diff_ev_left_correct = ...
        get_collapsed_cosine_sim(...
        correct_left_60_traces, error_right_06_traces, ...
        use_bin, which_measure);
    temp_same_choice_diff_ev_right_correct = ...
        get_collapsed_cosine_sim(...
        error_left_60_traces, correct_right_06_traces, ...
        use_bin, which_measure);
    temp_same_choice_diff_ev = cat(2, ...
        temp_same_choice_diff_ev_left_correct,...
        temp_same_choice_diff_ev_right_correct);
    diff_ev_same_choice_mean(use_bin) = nanmean(temp_same_choice_diff_ev);
    diff_ev_same_choice_sem(use_bin) = calcSEM(temp_same_choice_diff_ev');
    
    %diff choice same ev
    temp_diff_choice_same_ev_left = ...
        get_collapsed_cosine_sim(...
        correct_left_60_traces, error_left_60_traces, ...
        use_bin, which_measure);
    temp_diff_choice_same_ev_right = ...
        get_collapsed_cosine_sim(...
        correct_right_06_traces, error_right_06_traces, ...
        use_bin, which_measure);
    temp_diff_choice_same_ev = cat(2, ...
        temp_diff_choice_same_ev_left,...
        temp_diff_choice_same_ev_right);
    same_ev_diff_choice_mean(use_bin) = nanmean(temp_diff_choice_same_ev);
    same_ev_diff_choice_sem(use_bin) = calcSEM(temp_diff_choice_same_ev');
    
    %diff choice diff ev
    temp_diff_choice_diff_ev = ...
        get_collapsed_cosine_sim(...
        correct_left_60_traces, correct_right_06_traces, ...
        use_bin, which_measure);
    diff_ev_diff_choice_mean(use_bin) = nanmean(temp_diff_choice_diff_ev);
    diff_ev_diff_choice_sem(use_bin) = calcSEM(temp_diff_choice_diff_ev');
    
end

out.same_ev_same_choice.mean = same_ev_same_choice_mean;
out.same_ev_diff_choice.mean = same_ev_diff_choice_mean;
out.diff_ev_same_choice.mean = diff_ev_same_choice_mean;
out.diff_ev_diff_choice.mean = diff_ev_diff_choice_mean;

out.same_ev_same_choice.sem = same_ev_same_choice_sem;
out.same_ev_diff_choice.sem = same_ev_diff_choice_sem;
out.diff_ev_same_choice.sem = diff_ev_same_choice_sem;
out.diff_ev_diff_choice.sem = diff_ev_diff_choice_sem;


out.use_correlation = use_correlation;
out.yPosBins = dataCell{1}.imaging.yPosBins;

end

function all_sim = ...
    get_collapsed_cosine_sim(traces_1, traces_2, use_bin, which_measure)

cos_dist = pdist2(...
    squeeze(traces_1(:, use_bin, :))',...
    squeeze(traces_2(:, use_bin, :))', which_measure);
all_sim = 1 - reshape(cos_dist, 1, []);
end