%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150701_behaviorRegression';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
    
    %process 
    out = regressClustBehavior(correctRight60);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_correctRight60RegressBehav.mat',procList{dSet}{:}));
    save(saveName,'out');
end