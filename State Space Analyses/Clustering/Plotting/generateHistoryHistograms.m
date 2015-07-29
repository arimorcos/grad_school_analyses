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
    [mMat,cMat,clusterIDs,clusterCenters]=getClusteredMarkovMatrix(imTrials);
    
    % create histogram
    getClusteredTrajIntraHistorySig(imTrials,clusterIDs);
    
    % export
    toPPT(gcf);
    toPPT('setTitle',sprintf('%s\\_%s\\_HistoryHistogram',mouse,date));
    
    %close
    close all;
    
end 