%
saveFolder = '/mnt/7A08079708075215/DATA/Analyzed Data/160129_vogel_cluster_dim';

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
    out = getClusteredDimensionality(imTrials);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_cluster_dim.mat',procList{dSet}{:}));
    save(saveName,'out');
    
end