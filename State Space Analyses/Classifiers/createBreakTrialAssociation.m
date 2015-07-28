%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150728_brokenTrialAssociation';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

nShuffles = 100;

for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
     
    %get real accuracy 
    leftTurns = getCellVals(trials60,'result.leftTurn');
    [~,traces] = catBinnedTraces(trials60);
    accuracy = getSVMAccuracy(traces,leftTurns,'gamma',0.04);
    
    %get shuffleAccuracy 
    shuffleAccuracy = nan(nShuffles,length(accuracy));
    for shuffleInd = 1:nShuffles
        [shuffleTraces,leftTurns] = breakTrialAssociationForClassifier(trials60);
        shuffleAccuracy(shuffleInd,:) = getSVMAccuracy(shuffleTraces,leftTurns,'gamma',0.04);
    end
    
    yPosBins = imTrials{1}.imaging.yPosBins;
    
    % save 
    save(fullfile(saveFolder,sprintf('%s_%s_breakTrialAssociation60',mouse,date)),'accuracy','shuffleAccuracy','yPosBins');
%     save(fullfile(saveFolder,sprintf('%s_%s_breakTrialAssociation60',mouse,date)),'yPosBins','-append');
    
end

