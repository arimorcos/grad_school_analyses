%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151029_vogel_viewAngle_swap';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %view angle classifiers
    realClassifierOut = classifyNetEvGroupSegSVM(imTrials,...
        'viewAngleSwap',false,'gamma',0.2);
    swapClassifierOut = classifyNetEvGroupSegSVM(imTrials,...
        'viewAngleSwap',true,'gamma',0.2);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_viewAngleSwap.mat',procList{dSet}{:}));
    save(saveName,'realClassifierOut','swapClassifierOut');
end