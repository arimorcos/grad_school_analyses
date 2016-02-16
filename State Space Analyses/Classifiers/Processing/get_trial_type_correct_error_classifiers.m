%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/160210_vogel_trial_type_error_SVM';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
nShuffles = 100;
cParam = 4.4;
gamma = 0.04;

%get deltaPLeft
for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    yPosBins = imTrials{1}.imaging.yPosBins;
    
    %% trial_types
    
    % 6-0 
    sub = getTrials(imTrials, 'maze.numLeft==0,6');
    
    %get real class
    traces = catBinnedDeconvTraces(sub);
    leftTurn = getCellVals(sub,'result.leftTurn');
    
    % classify
    accuracy_60 = getSVMAccuracy(traces, leftTurn, 'cparam', cParam,...
        'gamma', gamma);
    
    % 5-1
    sub = getTrials(imTrials, 'maze.numLeft==1,5');
    
    %get real class
    traces = catBinnedDeconvTraces(sub);
    leftTurn = getCellVals(sub,'result.leftTurn');
    
    % classify
    accuracy_51 = getSVMAccuracy(traces, leftTurn, 'cparam', cParam,...
        'gamma', gamma);
    
    % 4-2
    sub = getTrials(imTrials, 'maze.numLeft==2,4');
    
    %get real class
    traces = catBinnedDeconvTraces(sub);
    leftTurn = getCellVals(sub,'result.leftTurn');
    
    % classify
    accuracy_42 = getSVMAccuracy(traces, leftTurn, 'cparam', cParam,...
        'gamma', gamma);
    
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_trial_types.mat',procList{dSet}{:}));
    save(saveName,'accuracy_60','accuracy_51','accuracy_42','yPosBins');
    
    %% correct vs. error
    
    % correct
    sub = getTrials(imTrials, 'result.correct==1');
    
    %get real class
    traces = catBinnedDeconvTraces(sub);
    leftTurn = getCellVals(sub,'result.leftTurn');
    
    % classify
    accuracy_correct = getSVMAccuracy(traces, leftTurn, 'cparam', cParam,...
        'gamma', gamma);
    
    % incorrect
    traces = catBinnedDeconvTraces(sub);
    sub = getTrials(imTrials, 'result.correct==0');
    
    %get real class
    traces = catBinnedDeconvTraces(sub);
    leftTurn = getCellVals(sub,'result.leftTurn');
    
    % classify
    accuracy_error = getSVMAccuracy(traces, leftTurn, 'cparam', cParam,...
        'gamma', gamma);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_correct_error.mat',procList{dSet}{:}));
    save(saveName,'accuracy_correct','accuracy_error','yPosBins');
    
end