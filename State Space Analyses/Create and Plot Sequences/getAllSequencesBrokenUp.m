%saveFolder 
saveFolder = '/Users/arimorcos/Data/Analyzed Data/160207_vogel_seq_left_right';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);
sel_thresh = 0;

for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:}, [], 'vogel_noSmooth');
    
    % filter based on selectivity index 
    sel_ind = getSelectivityIndex(imTrials);
    left_cells = find(max(sel_ind, [], 2) >= sel_thresh);
    right_cells = find(min(sel_ind, [], 2) <= -sel_thresh);
    
    %get sequence info 
    if ~isempty(left_cells)
        [~,seq_info_sort_left{dSet}] = ...
            makeLeftRightSeq(correctTrials,'cells',...
            {'maze.numLeft==6', 'maze.numLeft==0'}, ...
            true, left_cells);
    else
        seq_info_sort_left{dSet} = [];
    end
    if ~isempty(right_cells)
        [~,seq_info_sort_right{dSet}] = ...
            makeLeftRightSeq(correctTrials,'cells',...
            {'maze.numLeft==0', 'maze.numLeft==6'}, ...
            true, right_cells);
    else
        seq_info_sort_right{dSet} = [];
    end
end

% save 
save(sprintf('sequenceInfoAllMice_sel_thresh_%.2f.mat', sel_thresh),...
    'seq_info_sort_left', 'seq_info_sort_right');