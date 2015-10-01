%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150907_vogel_predictClusterInternal';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %filter to 5-1
%     imTrials = getTrials(imTrials,'maze.numLeft==1,2,3,4,5');
    
    %cluster 
    [~,~,clusterIDs,~] = getClusteredMarkovMatrix(imTrials,'oneClustering',false,'range',[0.7 0.95]);
    
    out = predictClusterInternalExternal(clusterIDs,imTrials);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_predictIntExt_intNetEv.mat',procList{dSet}{:}));
    save(saveName,'out');
end