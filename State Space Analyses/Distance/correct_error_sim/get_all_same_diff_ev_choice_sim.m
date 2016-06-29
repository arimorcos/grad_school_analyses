%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/160316_vogel_same_diff_ev_choice_sim';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    out_corr = get_same_diff_ev_choice_sim(imTrials, true);
    out_cos_sim = get_same_diff_ev_choice_sim(imTrials, false);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_same_diff_ev_choice_sim.mat',procList{dSet}{:}));
    save(saveName, 'out_corr','out_cos_sim');
    
end