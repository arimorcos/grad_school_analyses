%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150730_timeSinceTrialStart';

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
    
    %classifier 
    classifierOut = classifyTimeSinceTrialStartSVR(imTrials,'shouldShuffle',true,'nshuffles',1000);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_timeSinceTrialStart_allTrials.mat',procList{dSet}{:}));
    save(saveName,'classifierOut');
    
    %classifier 
    prevCorrect = getTrials(imTrials,'result.prevCorrect==1');
    classifierOut = classifyTimeSinceTrialStartSVR(prevCorrect,'shouldShuffle',true,'nshuffles',1000);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_timeSinceTrialStart_prevCorrect.mat',procList{dSet}{:}));
    save(saveName,'classifierOut');
end 