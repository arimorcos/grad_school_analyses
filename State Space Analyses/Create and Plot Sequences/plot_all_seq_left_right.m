%% plot left sorted
remove_thresh = 0.7;
seq_info = seq_info_sort_left;

% remove empty cells 
seq_info = seq_info(~cellfun(@isempty, seq_info));

binLengths = cellfun(@(x) length(x.bins),seq_info);

%get min binlengths 
[minBinLength, ind] = min(binLengths);

%concatenate 
croppedTraces = cellfun(@(x) {x.normTraces{1}(:,1:minBinLength) x.normTraces{2}(:, 1:minBinLength)},...
    seq_info,'UniformOutput',false);
croppedTraces = cat(1,croppedTraces{:});

% break up into first and second
first_traces_left = cat(1, croppedTraces{:, 1});
second_traces_left = cat(1, croppedTraces{:, 2});

%resort
[~,maxInd] = max(first_traces_left,[],2);
[~,sortOrder] = sort(maxInd);
first_traces_left = first_traces_left(sortOrder,:);
second_traces_left = second_traces_left(sortOrder, :);

%cutoff 
cutoff = 3;
first_traces_left(first_traces_left> cutoff) = cutoff;
second_traces_left(second_traces_left> cutoff) = cutoff;

% filter cells 
remove_cells = mean(cat(2, first_traces_left, second_traces_left), 2) > remove_thresh;
first_traces_left(remove_cells, :) = [];
second_traces_left(remove_cells, :) = [];

%plot 
figLeft = plotSequences({first_traces_left, second_traces_left},...
    seq_info{ind}.bins,...
    {'Correct left 6-0 (sorted)', 'Correct right 0-6'},...
    seq_info{1}.normInd,...
    seq_info{1}.colorLab,[]);

%% plot right sorted
seq_info = seq_info_sort_right;

% remove empty cells 
seq_info = seq_info(~cellfun(@isempty, seq_info));

binLengths = cellfun(@(x) length(x.bins),seq_info);

%get min binlengths 
[minBinLength, ind] = min(binLengths);

%concatenate 
croppedTraces = cellfun(@(x) {x.normTraces{1}(:,1:minBinLength) x.normTraces{2}(:, 1:minBinLength)},...
    seq_info,'UniformOutput',false);
croppedTraces = cat(1,croppedTraces{:});

% break up into first and secondsecond_traces_right
first_traces_right = cat(1, croppedTraces{:, 1});
second_traces_right = cat(1, croppedTraces{:, 2});

%resort
[~,maxInd] = max(first_traces_right,[],2);
[~,sortOrder] = sort(maxInd);
first_traces_right = first_traces_right(sortOrder,:);
second_traces_right = second_traces_right(sortOrder, :);

%cutoff 
cutoff = 3;
first_traces_right(first_traces_right> cutoff) = cutoff;
second_traces_right(second_traces_right> cutoff) = cutoff;

% filter cells 
remove_cells = mean(cat(2, first_traces_right, second_traces_right), 2) > remove_thresh;
first_traces_right(remove_cells, :) = [];
second_traces_right(remove_cells, :) = [];

%plot 
figRight = plotSequences({first_traces_right, second_traces_right},...
    seq_info{ind}.bins,...
    {'Correct right 0-6 (sorted)', 'Correct left 6-0'},...
    seq_info{1}.normInd,...
    seq_info{1}.colorLab,[]);



%% plot preffered vs. non-preffered

% concatenate each 
pref_traces = cat(1, first_traces_left, first_traces_right);
nonpref_traces = cat(1, second_traces_left, second_traces_right);

%resort
[~,maxInd] = max(pref_traces,[],2);
[~,sortOrder] = sort(maxInd);
pref_traces = pref_traces(sortOrder,:);
nonpref_traces = nonpref_traces(sortOrder, :);
% pref_traces = pref_traces(1:2:end, :);
% nonpref_traces = nonpref_traces(1:2:end, :);

<<<<<<< Updated upstream
pref_traces(pref_traces < 0.3) = 0;
nonpref_traces(nonpref_traces < 0.3) = 0;
=======
% filter cells 
remove_thresh = 1;
remove_cells = mean(cat(2, pref_traces, nonpref_traces), 2) > remove_thresh;
pref_traces(remove_cells, :) = [];
nonpref_traces(remove_cells, :) = [];

% filter 
zero_thresh = 0;
pref_traces(pref_traces < zero_thresh) = 0;
nonpref_traces(nonpref_traces < zero_thresh) = 0;

%remove cells that are less selective 
mean_diff = max(abs(pref_traces - nonpref_traces), [], 2);
keep_cells = mean_diff > 0;
pref_traces = pref_traces(keep_cells, :);
nonpref_traces = nonpref_traces(keep_cells, :);
>>>>>>> Stashed changes

% plot
figPref = plotSequences({pref_traces, nonpref_traces},...
    seq_info{ind}.bins,...
    {'Preferred', 'Non-preferred'},...
    seq_info{1}.normInd,...
    seq_info{1}.colorLab,[]);

<<<<<<< Updated upstream
%% plot non-selective
seq_info = seq_info_non_sel;

=======
colormap(jet);

%% plot turn period pref non pref
% concatenate each 
pref_traces = cat(1, first_traces_left, first_traces_right);
nonpref_traces = cat(1, second_traces_left, second_traces_right);

%resort
[~,maxInd] = max(pref_traces,[],2);
[~,sortOrder] = sort(maxInd);
pref_traces = pref_traces(sortOrder,:);
nonpref_traces = nonpref_traces(sortOrder, :);
% pref_traces = pref_traces(1:2:end, :);
% nonpref_traces = nonpref_traces(1:2:end, :);

% filter cells 
remove_thresh = 1;
remove_cells = mean(cat(2, pref_traces, nonpref_traces), 2) > remove_thresh;
pref_traces(remove_cells, :) = [];
nonpref_traces(remove_cells, :) = [];

% filter 
zero_thresh = 0;
pref_traces(pref_traces < zero_thresh) = 0;
nonpref_traces(nonpref_traces < zero_thresh) = 0;

%remove cells that are less selective 
mean_diff = max(abs(pref_traces - nonpref_traces), [], 2);
keep_cells = mean_diff > 0;
pref_traces = pref_traces(keep_cells, :);
nonpref_traces = nonpref_traces(keep_cells, :);

%filter to turn period
% which_cells = 1:191;
which_cells = 173:size(pref_traces, 1);
bin_ind = 104:length(seq_info{ind}.bins);
pref_traces = pref_traces(which_cells, bin_ind);
nonpref_traces = nonpref_traces(which_cells, bin_ind);

% plot
figPref = plotSequences({pref_traces, nonpref_traces},...
    seq_info{ind}.bins(bin_ind),...
    {'Preferred', 'Non-preferred'},...
    seq_info{1}.normInd,...
    seq_info{1}.colorLab,[]);

colormap(jet);

%% plot non-selective

seq_info = seq_info_non_sel;

% remove empty cells 
>>>>>>> Stashed changes
seq_info = seq_info(~cellfun(@isempty, seq_info));

binLengths = cellfun(@(x) length(x.bins),seq_info);

%get min binlengths 
[minBinLength, ind] = min(binLengths);

<<<<<<< Updated upstream
=======
% filter based on activity
for i = 1:length(seq_info)
    keep_cells = seq_info{i}.trans_rate > 10;
    seq_info{i}.normTraces = {seq_info{i}.normTraces{1}(keep_cells,:),...
        seq_info{i}.normTraces{2}(keep_cells, :)};
end

>>>>>>> Stashed changes
%concatenate 
croppedTraces = cellfun(@(x) {x.normTraces{1}(:,1:minBinLength) x.normTraces{2}(:, 1:minBinLength)},...
    seq_info,'UniformOutput',false);
croppedTraces = cat(1,croppedTraces{:});

% break up into first and second
first_traces_left = cat(1, croppedTraces{:, 1});
second_traces_left = cat(1, croppedTraces{:, 2});

<<<<<<< Updated upstream
=======

>>>>>>> Stashed changes
%resort
[~,maxInd] = max(first_traces_left,[],2);
[~,sortOrder] = sort(maxInd);
first_traces_left = first_traces_left(sortOrder,:);
second_traces_left = second_traces_left(sortOrder, :);

%cutoff 
cutoff = 3;
first_traces_left(first_traces_left> cutoff) = cutoff;
second_traces_left(second_traces_left> cutoff) = cutoff;

<<<<<<< Updated upstream
=======
%cutoff 
cutoff = 0.3;
first_traces_left(first_traces_left< cutoff) = 0;
second_traces_left(second_traces_left< cutoff) = 0;

>>>>>>> Stashed changes
% filter cells 
remove_cells = mean(cat(2, first_traces_left, second_traces_left), 2) > remove_thresh;
first_traces_left(remove_cells, :) = [];
second_traces_left(remove_cells, :) = [];

<<<<<<< Updated upstream
first_traces_left(first_traces_left < 0.4) = 0;
second_traces_left(second_traces_left < 0.4) = 0;

%plot 
figLeft = plotSequences({first_traces_left, second_traces_left},...
    seq_info{ind}.bins,...
    {'Correct left 6-0 trials (sorted)', 'Correct right 0-6 trials'},...
=======
%plot 
figLeft = plotSequences({first_traces_left, second_traces_left},...
    seq_info{ind}.bins,...
    {'Correct left 6-0 (sorted)', 'Correct right 0-6'},...
>>>>>>> Stashed changes
    seq_info{1}.normInd,...
    seq_info{1}.colorLab,[]);

colormap(jet);