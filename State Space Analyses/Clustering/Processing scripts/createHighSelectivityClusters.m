%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150703_highSelectivityClusteringDeltaPoint';

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
    [~,sortOrder] = sort(max(abs(selInd),[],2),'descend');
    
    %get top 5%
    frac = 0.05;
    keepNum  = round(frac*length(sortOrder));
    
    %get actual deltaPoint
    [acc,sigMat,deltaPoint] = calcTrajPredictability(left60,'whichNeurons',sortOrder(1:keepNum));
    
    %get trial matched shuffle 
    nShuffles = 100;
    shuffleDeltaPoint = cell(nShuffles,1);
    for shuffleInd = 1:nShuffles
        shuffleOrder = shuffleArray(sortOrder);
        [~,~,shuffleDeltaPoint{shuffleInd}] = calcTrajPredictability(left60,'whichNeurons',shuffleOrder(1:keepNum));
    end
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_left60HighSelectivityNeurons%d.mat',procList{dSet}{:},frac*100));
    save(saveName,'deltaPoint','shuffleDeltaPoint');
end