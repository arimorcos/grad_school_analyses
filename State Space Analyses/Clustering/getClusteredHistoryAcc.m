%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150728_clusteredHistAcc';

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
    
    %cluster
    [mMat,cMat,clusterIDs,clusterCenters]=getClusteredMarkovMatrix(imTrials,...
        'oneclustering',false,'perc',10,'traceType','deconv');
    
    %get accuracy 
    [accuracy,shuffleAccuracy,nSTD] = predictHistoryFromClusters(clusterIDs,imTrials);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_clusteredHistAcc_tMatch_perc_10_deconv.mat',procList{dSet}{:}));
    save(saveName,'accuracy','shuffleAccuracy','nSTD');
end 