%saveFolder 
saveFolder = '/mnt/7A08079708075215/DATA/Analyzed Data/160203_vogel_conditional_distances';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);


%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    % process
    out = getConditionalDistances(imTrials);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_conditional_distances.mat',procList{dSet}{:}));
    save(saveName,'out');
end 


