%saveFolder 
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151013_vogel_netEvBehavDist';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %cluster 
    [~,~,clusterIDs,~] = getClusteredMarkovMatrix(imTrials);
    
    %get leftTurns
%     leftTurns = getCellVals(imTrials,'result.leftTurn');
    netEv = getNetEvidence(imTrials);
    
    %get behavioral distribution
    for i = 2:7
        out{i-1} = clusterBehavioralDistribution(clusterIDs(:,i),netEv(:,i-1));
    end
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_netEvClusterBehavDist.mat',procList{dSet}{:}));
    save(saveName,'out');
end