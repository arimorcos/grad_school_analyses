%saveFolder
saveFolder = 'D:\DATA\Analyzed Data\150805_prevBehav';
prevFolder = 'D:\DATA\Analyzed Data\150602_SVMClassifiers';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

viewRange = 5;

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
    
    %load in prevTurn
    load(fullfile(prevFolder,sprintf('%s_%s_prevTurn_allTrials_out.mat',...
        procList{dSet}{:})));
    
    %get behavioral variablea
    catDataFrames = catBinnedDataFrames(imTrials);
    behavVar = catDataFrames(2:6,:,:);
    
    %get prevTurn
    prevTurn = getCellVals(imTrials,'result.prevTurn');
    
    %get acc
    behavAccuracy = getSVMAccuracy(behavVar, prevTurn);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_prevTurnBehavior.mat',procList{dSet}{:}));
    save(saveName,'behavAccuracy','accuracy','yPosBins','shuffleAccuracy');
    
    %load in prevCorrect
    load(fullfile(prevFolder,sprintf('%s_%s_prevCorrect_allTrials_out.mat',...
        procList{dSet}{:})));
    
    %get prevTurn
    prevCorrect = getCellVals(imTrials,'result.prevCorrect');
    
    %get acc
    behavAccuracy = getSVMAccuracy(behavVar, prevCorrect);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_prevCorrectBehavior.mat',procList{dSet}{:}));
    save(saveName,'behavAccuracy','accuracy','yPosBins','shuffleAccuracy');

end