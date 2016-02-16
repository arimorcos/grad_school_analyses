%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/160210_vogel_trial_type_error_SVM';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
nShuffles = 10000;
cParam = 4.4;
gamma = 0.04;

%get deltaPLeft
for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    yPosBins = imTrials{1}.imaging.yPosBins;
    
    % incorrect
    sub = getTrials(imTrials, 'result.correct==0');
    
    %get real class
    traces = catBinnedDeconvTraces(sub);
    traces = traces(:, 2:5, :);
    leftTurn = getCellVals(sub,'result.leftTurn');
    
    % classify
    [accuracy,shuffleAccuracy] = classifyAndShuffle(traces,leftTurn,...
        {'accuracy','shuffleAccuracy'},'nshuffles',nShuffles,...
        'cparam',cParam,'gamma',gamma);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_error_sig.mat',procList{dSet}{:}));
    save(saveName,'accuracy','shuffleAccuracy','yPosBins');
    
end