%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150910_vogel_behavRegression';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %process 
    out = regressClustBehavior(correctRight60);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_correctRight60RegressBehav.mat',procList{dSet}{:}));
    save(saveName,'out');
    
    out = regressClustBehavior(correctLeft60);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_correctLeft60RegressBehav.mat',procList{dSet}{:}));
    save(saveName,'out');
    
%     out = regressClustBehavior(left60);
%     
%     %save 
%     saveName = fullfile(saveFolder,sprintf('%s_%s_left60RegressBehav.mat',procList{dSet}{:}));
%     save(saveName,'out');
%     
%     out = regressClustBehavior(right60);
%     
%     %save 
%     saveName = fullfile(saveFolder,sprintf('%s_%s_right60RegressBehav.mat',procList{dSet}{:}));
%     save(saveName,'out');
end