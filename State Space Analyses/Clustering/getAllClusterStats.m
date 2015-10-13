%
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151011_vogel_clusterStats';

% get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');

    %process
    stats = getClusterStats(imTrials);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_clusterStats.mat',procList{dSet}{:}));
    save(saveName,'stats');
    
end