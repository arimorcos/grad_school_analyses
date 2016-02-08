%saveFolder 
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151006_test';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
% for dSet = 7
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %get cluster ids 
%     imTrials = getTrials(imTrials,'maze.numLeft==0,1,2,3,4,5');
    [~,~,clusterIDs,~] = getClusteredMarkovMatrix(imTrials,...
        'traceType','deconv','perc',10);
    
    %get accuracy 
    [accuracy,shuffleAccuracy,nSTD,trialInfo] = ...
        predictHistoryFromClusters(clusterIDs, imTrials, 100);
    
    %save 
    saveName = fullfile(saveFolder,sprintf(....
        '%s_%s_clusteredHistAcc_tMatch_perc_10_deconv_smooth10.mat',procList{dSet}{:}));
    save(saveName,'accuracy','shuffleAccuracy','nSTD','trialInfo');
end 