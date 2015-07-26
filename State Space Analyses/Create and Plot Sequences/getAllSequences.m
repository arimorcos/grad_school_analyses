%saveFolder 
saveFolder = '/Users/arimorcos/Data/Analyzed Data/150726_allSeq';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
    
    %get sequence info 
    [~,seqInfo{dSet}] = makeLeftRightSeq(imTrials,'cells',{''});
   
    
end

% save 
save('sequenceInfoAllMice','seqInfo');