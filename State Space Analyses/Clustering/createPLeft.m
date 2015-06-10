%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150608_deltaPLeft';

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
    
    %get deltaPLeft 
    deltaPLeft = calcPLeftChange(clusterIDs,imTrials);
    
    %get netEvidence 
    netEvidence = getNetEvidence(imTrials);
    
    %get segWeights 
    [segWeights, confInt] = getSegWeights(imTrials);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_deltaPLeft.mat',procList{dSet}{:}));
    save(saveName,'deltaPLeft','netEvidence','segWeights','confInt');
end