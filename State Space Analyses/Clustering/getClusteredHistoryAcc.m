%saveFolder 
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151005_vogel_clusteredHistAcc_separate';

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
    
    %get accuracy 
    [accuracy,shuffleAccuracy,nSTD,trialInfo] = ...
        predictHistoryFromClustersSeparateClustering(imTrials);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_clusteredHistAcc_tMatch_perc_10_sep.mat',procList{dSet}{:}));
    save(saveName,'accuracy','shuffleAccuracy','nSTD','trialInfo');
end 