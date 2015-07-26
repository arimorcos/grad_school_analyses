%saveFolder 
saveFolder = '/Users/arimorcos/Data/Analyzed Data/150726_selIndAll';

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
   
    
end

% save 
save(fullfile(saveFolder,'sequenceInfoAllMice'),'selIndAll');