%
saveFolder = '/mnt/7A08079708075215/DATA/Analyzed Data/160324_vogel_new_cluster_stats';

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