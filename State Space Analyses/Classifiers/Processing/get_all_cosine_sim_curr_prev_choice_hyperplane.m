%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/160314_vogel_cosine_sim_curr_prev_choice_hyperplane';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);


%get deltaPLeft
for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    [cosine_sim, shuffle_cosine_sim] = ...
        get_cosine_sim_curr_prev_choice_hyperplane(imTrials);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_cosine_sim.mat',procList{dSet}{:}));
    save(saveName, 'cosine_sim','shuffle_cosine_sim');
    
end