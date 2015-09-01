%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150726_transientStatsAll';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
    
    allStats(dSet) = getTransientStats(imTrials,'limitToSeg',true);
   
    
end

stats.meanNTransients = cat(1,allStats.meanNTransients);
stats.stdNTransients = cat(1,allStats.stdNTransients);
stats.meanTransLength = cat(2,allStats.meanTransLength);
stats.stdTransLEngth = cat(2,allStats.stdTransLEngth);
stats.meanFracLength = cat(1,allStats.meanFracLength);
stats.stdFracLength = cat(1,allStats.stdFracLength);

% save 
save(fullfile(saveFolder,'allTransientStatsSegPeriod'),'stats');