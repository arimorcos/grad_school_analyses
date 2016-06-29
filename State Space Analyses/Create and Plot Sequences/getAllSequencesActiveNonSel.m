%saveFolder 
saveFolder = '/mnt/7A08079708075215/DATA/Analyzed Data/160207_vogel_seq_left_right';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);
sel_thresh = 0.25;

for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    [dataCell, imTrials] = ...
        loadProcessed(procList{dSet}{:}, {'dataCell', 'imTrials'}, 'vogel_noSmooth');
    
    dataCell = threshDataCell(dataCell);
    dataCell = filterROIGroups(dataCell, 1);
    correctTrials = getTrials(dataCell, 'result.correct==1;imaging.imData==1');
    correctTrials = binFramesByYPos(correctTrials, 5);
    
    % filter based on selectivity index 
    sel_ind = getSelectivityIndex(imTrials);
    left_cells = find(max(sel_ind, [], 2) >= sel_thresh);
    right_cells = find(min(sel_ind, [], 2) <= -sel_thresh);
    non_sel = find(max(sel_ind, [], 2) < sel_thresh & ...
        min(sel_ind, [], 2) > -sel_thresh);
    
    % find active cells 
    trans_rate = get_transients_per_min(dataCell);
    trans_rate_left_cells = trans_rate(left_cells);
    trans_rate_right_cells = trans_rate(right_cells);
    trans_rate_non_sel_cells = trans_rate(non_sel);
    
    %get sequence info 
    if ~isempty(left_cells)
        [~,seq_info_sort_left{dSet}] = ...
            makeLeftRightSeq(correctTrials,'cells',...
            {'maze.numLeft==6', 'maze.numLeft==0'}, ...
            true, left_cells);
        seq_info_sort_left{dSet}.trans_rate = trans_rate_left_cells;
    else
        seq_info_sort_left{dSet} = [];
    end
    if ~isempty(right_cells)
        [~,seq_info_sort_right{dSet}] = ...
            makeLeftRightSeq(correctTrials,'cells',...
            {'maze.numLeft==0', 'maze.numLeft==6'}, ...
            true, right_cells);
        seq_info_sort_right{dSet}.trans_rate = trans_rate_right_cells;
    else
        seq_info_sort_right{dSet} = [];
    end
    
    % get non-selective sequence info 
    if ~isempty(left_cells)
        [~,seq_info_non_sel{dSet}] = ...
            makeLeftRightSeq(correctTrials,'cells',...
            {'maze.numLeft==6', 'maze.numLeft==0'}, ...
            true, non_sel);
        seq_info_non_sel{dSet}.trans_rate = trans_rate_non_sel_cells;
    else
        seq_info_non_sel{dSet} = [];
    end
    
end

% save 
save(sprintf('seq_info_all_mice_theshdff_thresh_%.2f_non_sel_active.mat', sel_thresh),...
    'seq_info_sort_left', 'seq_info_sort_right', 'seq_info_non_sel');