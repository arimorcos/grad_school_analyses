%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/160315_vogel_pca_dim/mean_subtract';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
which_var = 5:5:100;

%get deltaPLeft
for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    dim = getPCADimensionality(imTrials, which_var);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_pca_dim.mat',procList{dSet}{:}));
    save(saveName, 'dim','which_var');
    
end