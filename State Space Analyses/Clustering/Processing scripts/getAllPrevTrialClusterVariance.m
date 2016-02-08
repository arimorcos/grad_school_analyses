%saveFolder
saveFolder = 'D:\DATA\Analyzed Data\150919_vogel_prevClusterVar';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %cluster
    out = calcPrevTrialClusterVariance(imTrials);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_prevTrialClusterVar.mat',procList{dSet}{:}));
    save(saveName,'out');
end