%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150611_clusteredBehavior';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
    
    %cluster 
    [~,~,clusterIDs,~] = getClusteredMarkovMatrix(imTrials);
    
    %get leftTurns
    leftTurns = getCellVals(imTrials,'result.leftTurn');
    
    %get behavioral distribution
    out = clusterBehavioralDistribution(clusterIDs(:,10),leftTurns);    
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_clusterBehavDist.mat',procList{dSet}{:}));
    save(saveName,'out');
end