%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150727_netEvIndAll';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

netEvIndAll = [];
shuffleNetEvIndAll = [];

for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
    
    %get sequence info 
    netEvIndAll = cat(1,netEvIndAll,getNetEvidenceSelectivity(imTrials));
    shuffleNetEvIndAll = cat(1,shuffleNetEvIndAll,getNetEvidenceSelectivity(imTrials,true));
   
    
end

% save 
save(fullfile(saveFolder,'netEvIndAllMice'),'netEvIndAll','shuffleNetEvIndAll');