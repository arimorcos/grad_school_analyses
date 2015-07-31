%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150731_deltaSegOffsetVec';

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
    
    %get deltaSegOffset 
    [deltaSegStart, deltaSegEnd, rOffset] = getDeltaSegOffset(imTrials);
    [deltaSegStart, deltaVec, rVector] = getDeltaSegVectors(imTrials);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_deltaSegOffsetVector.mat',procList{dSet}{:}));
    save(saveName,'deltaSegEnd','deltaSegStart','rVector','rOffset','deltaVec');
end 