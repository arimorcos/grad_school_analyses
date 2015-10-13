%
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151013_vogel_clusterIDs';

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
    [mMat,cMat,clusterIDs,clusterCenters] = getClusteredMarkovMatrix(imTrials);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_clusterIDs.mat',procList{dSet}{:}));
    save(saveName,'clusterIDs');
    
end