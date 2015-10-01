%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150925_vogel_addin_selInd';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);


%get deltaPLeft
% for dSet = 1:nDataSets
for dSet = 8;
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %get sort order 
    selInd = getSelectivityIndex(imTrials);
    maxSelInd = max(abs(selInd),[],2);
    [~,sortOrder] = sort(maxSelInd);
    
    %get classifier out for addin 
    acc = getLeftRightAccuracyNeuronFallout(imTrials, sortOrder, false, 20);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_turnAddIn_selInd.mat',procList{dSet}{:}));
    save(saveName,'acc');
end 


