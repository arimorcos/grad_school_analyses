%saveFolder 
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151006_vogel_overlapCorrDeltaPLeft';

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
    
    out = calcOverlapCorrCoefVsDeltaPLeft(imTrials);
    
    %save 
    saveName = fullfile(saveFolder,sprintf(....
        '%s_%s_overlapCorrDeltaPLeft.mat',procList{dSet}{:}));
    save(saveName,'out');
end 