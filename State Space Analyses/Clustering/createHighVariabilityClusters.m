%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150703_highVariabilityClusteringDeltaPoint';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
    
    %get selectivity index
    selInd = getSelectivityIndex(imTrials);
    [~,sortOrder] = sort(max(abs(selInd),[],2),'ascend');
    
    %get bottom 50%
    frac = 1;
    keepNum  = round(frac*length(sortOrder));
    
    %get deltaPoint
    [acc,sigMat,deltaPoint] = calcTrajPredictability(left60,'whichNeurons',sortOrder(1:keepNum));
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_left60HighVariabilityNeurons%d.mat',procList{dSet}{:},frac*100));
    save(saveName,'deltaPoint');
end