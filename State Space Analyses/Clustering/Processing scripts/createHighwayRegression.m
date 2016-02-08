%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150707_ridgeTurnCluster';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
% for dSet = 7
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
    
    out = indNeuronClusterRegression(trials60);    
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_ridge60.mat',procList{dSet}{:}));
    save(saveName,'out');
end 