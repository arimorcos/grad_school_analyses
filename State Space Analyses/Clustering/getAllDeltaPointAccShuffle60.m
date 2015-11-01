%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151027_vogel_shuffle60_deltaPointAcc';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);


%get deltaPLeft
for dSet = 1:nDataSets
    % for dSet = 7
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %get correct60 
    correct60 = getTrials(imTrials,'result.correct==1;maze.numLeft==0,6');
    shuffle60 = shuffleCellAssociationsWithin60(imTrials);
    
    %get deconv all
    [~,~,deltaPoint,nUnique] = calcTrajPredictabilityUnified(correct60);
    [~,~,deltaPointShuffle,nUniqueShuffle] = calcTrajPredictabilityUnified(shuffle60);
    
    %save
    saveName = fullfile(saveFolder,sprintf(...
        '%s_%s_deltaPoint_shuffle60.mat',...
        procList{dSet}{:}));
    save(saveName,'deltaPointShuffle','nUniqueShuffle',...
        'deltaPoint','nUnique');
end