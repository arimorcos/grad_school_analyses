%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/160316_vogel_correct_error_cosine_sim';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    out_corr = get_correct_error_cosine_sim(imTrials, true);
    out_cos_sim = get_correct_error_cosine_sim(imTrials, false);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_correct_error_sim.mat',procList{dSet}{:}));
    save(saveName, 'out_corr','out_cos_sim');
    
end