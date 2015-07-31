%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150726_selIndAll';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
    
    %get sequence info 
    selIndAll{dSet} = getSelectivityIndex(imTrials);
    shuffleSelIndAll{dSet} = getSelectivityIndex(imTrials,true);
   
    
end

% save 
save(fullfile(saveFolder,'selIndAll'),'selIndAll','shuffleSelIndAll');