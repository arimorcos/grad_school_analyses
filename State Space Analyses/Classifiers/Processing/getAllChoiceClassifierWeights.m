%saveFolder
saveFolder = '/mnt/7A08079708075215/DATA/Analyzed Data/160610_vogel_svm_weights_choice_linear';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
nShuffles = 100;
cParam = 4.4;
gamma = 0.04;


whichSets = 1:nDataSets;

%get deltaPLeft
for dSet = 1:nDataSets
    
    if ~ismember(dSet,whichSets)
        continue;
    end
    
    % for dSet = 8
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth30');
    
    %get traces
    traces = catBinnedDeconvTraces(imTrials);
    
    yPosBins = imTrials{1}.imaging.yPosBins;
    trace_points = getMazePoints(traces, yPosBins);    
    

    
    %get left turns 
    leftTurns = getCellVals(imTrials, 'result.leftTurn');
    
    [accuracy,~,~,~,~,svmModel] = getSVMAccuracy(trace_points(:,10,:), leftTurns, 'kernel', 'linear');
    svmModel = svmModel{1};
    svm_weights = getSVMWeights(svmModel);
    
    % get selectivity 
    sel_ind = getSelectivityIndex(imTrials);
    sel_ind = max(abs(sel_ind), [], 2);
    
    % test for bottom 50% 
    num_cells = length(sel_ind);
    [~, sort_order] = sort(sel_ind);
    [accuracy_bottom50,~,~,~,~,svmModel_bottom50] = ...
        getSVMAccuracy(trace_points(sort_order(1:round(num_cells/2)),10,:), leftTurns, 'kernel', 'linear');
    sel_ind_bottom50 = sel_ind(sort_order(1:round(num_cells/2)));
    svmModel_bottom50 = svmModel_bottom50{1};
    svm_weights_bottom50 = getSVMWeights(svmModel_bottom50);

    saveName = fullfile(saveFolder,sprintf('%s_%s_svm_weights_choice.mat',procList{dSet}{:}));
    save(saveName, 'svmModel','svmModel_bottom50', 'accuracy', 'accuracy_bottom50',...
        'svm_weights_bottom50', 'svm_weights', 'sel_ind', 'sel_ind_bottom50');
    
end