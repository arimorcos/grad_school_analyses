%
saveFolder = 'D:\DATA\Analyzed Data\150908_vogel_first4Same';

get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');

    %process
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_mazeStartError.mat',procList{dSet}{:}));
    save(saveName,);
    
end