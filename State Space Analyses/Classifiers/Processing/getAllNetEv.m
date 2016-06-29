%saveFolder 
saveFolder = '/Users/arimorcos/Data/Analyzed Data/160312_vogel_newNetEv_noTrain33';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);


%get deltaPLeft
for dSet = 6:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %process
    classifierOut = classifyNetEvGroupSegSVM(imTrials, 'do_not_train_33', true);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_netEvSVR.mat',procList{dSet}{:}));
    save(saveName,'classifierOut');
end 