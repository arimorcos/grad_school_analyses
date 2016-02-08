%saveFolder 
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151008_vogel_indNeuron_ClusterTurn_AddRegression';

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
    
    % get indNeuron stats
    out = getIndNeuronClusterTurnAddRegression(imTrials);
    
    %save 
    saveName = fullfile(saveFolder,sprintf(....
        '%s_%s_clusterTurnAddReg.mat',procList{dSet}{:}));
    save(saveName,'out');
end 