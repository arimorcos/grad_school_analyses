%
saveFolder = '/Users/arimorcos/Data/Analyzed Data/160310_vogel_trial_pair_overlap_frac_trials_clustered';

% get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
num_boot = 20;

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    fracTogether = [];
    for boot = 1:num_boot
        [tempFracTogether, fracTrials] = calcTrialPairOverlapVsFracClustered(imTrials);
        fracTogether = cat(1, fracTogether, tempFracTogether);
    end
    fracTogether = mean(fracTogether);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_trial_overlap.mat',procList{dSet}{:}));
    save(saveName,'fracTogether', 'fracTrials');
    
end