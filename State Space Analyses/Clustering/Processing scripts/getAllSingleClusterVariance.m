%saveFolder
saveFolder = '/mnt/7A08079708075215/DATA/Analyzed Data/160216_vogel_single_cluster_var';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
nShuffles = 1000;

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dat aset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %cluster
    out = calcSingleClusterVariance(imTrials, true, nShuffles);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_clusterVar.mat',procList{dSet}{:}));
    save(saveName,'out');
end