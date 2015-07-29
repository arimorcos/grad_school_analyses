%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150602_SVMClassifiers';

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
    
    %get traces 
    yPosBins = imTrials{1}.imaging.yPosBins;
    firstSegInd = yPosBins >= 0 & yPosBins < 80;
    yPosBins = yPosBins(firstSegInd);
    [~,traces] = catBinnedTraces(imTrials);
    traces = traces(:,firstSegInd,:);
    
    %get realClass
    mazePatterns = getMazePatterns(imTrials);
    realClass = mazePatterns(:,1);
    
    %get accuracy 
    [accuracy,shuffleAccuracy] = classifyAndShuffle(traces,realClass,{'accuracy','shuffleAccuracy'},'nshuffles',100);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_firstSeg_allTrials_out.mat',procList{dSet}{:}));
    save(saveName,'accuracy','shuffleAccuracy','yPosBins');
end 