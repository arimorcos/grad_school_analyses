%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150801_netEvidenceAddIn';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);


%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
    
    %get sort order 
    netEvInd = getNetEvidenceSelectivity(imTrials);
    [~,sortOrder] = sort(netEvInd);
    
    %get classifier out for addin 
    classifierOut = getNetEvidenceNeuronAddIn(imTrials,sortOrder);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_netEvAddIn.mat',procList{dSet}{:}));
    save(saveName,'classifierOut');
end 