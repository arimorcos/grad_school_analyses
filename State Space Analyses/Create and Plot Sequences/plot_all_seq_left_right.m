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

% break up into first and second
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

pref_traces(pref_traces < 0.3) = 0;
nonpref_traces(nonpref_traces < 0.3) = 0;

% plot
figPref = plotSequences({pref_traces, nonpref_traces},...
    seq_info{ind}.bins,...
    {'Preferred', 'Non-preferred'},...
    seq_info{1}.normInd,...
    seq_info{1}.colorLab,[]);

%% plot non-selective
seq_info = seq_info_non_sel;

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

first_traces_left(first_traces_left < 0.4) = 0;
second_traces_left(second_traces_left < 0.4) = 0;

%plot 
figLeft = plotSequences({first_traces_left, second_traces_left},...
    seq_info{ind}.bins,...
    {'Correct left 6-0 trials (sorted)', 'Correct right 0-6 trials'},...
    seq_info{1}.normInd,...
    seq_info{1}.colorLab,[]);

colormap(jet);