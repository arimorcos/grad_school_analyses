%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150909_vogel_clusteredHistAcc';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 7:nDataSets
% for dSet = 7
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %cluster
    [mMat,cMat,clusterIDs,clusterCenters]=getClusteredMarkovMatrix(imTrials,...
        'oneclustering',false,'perc',10,'traceType','deconv');
    
    %get accuracy 
    [accuracy,shuffleAccuracy,nSTD] = predictHistoryFromClusters(clusterIDs,imTrials);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_clusteredHistAcc_tMatch_perc_10.mat',procList{dSet}{:}));
    save(saveName,'accuracy','shuffleAccuracy','nSTD');
end 