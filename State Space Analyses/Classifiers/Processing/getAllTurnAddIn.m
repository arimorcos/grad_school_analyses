%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150925_addIn_test';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);


%get deltaPLeft
for dSet = 3:nDataSets
% for dSet = 8;
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %get sort order 
    loadStr = sprintf('D:\\DATA\\Analyzed Data\\151013_vogel_singleNeuronSVMs_boot\\%s_%s_upcomingTurn_deconv.mat',procList{dSet}{:});
    load(loadStr);
    maxAcc = max(accuracy,[],2);
    [~,sortOrder] = sort(maxAcc);
    
    %get classifier out for addin 
    acc = getLeftRightAccuracyNeuronFallout(imTrials, sortOrder, false, 1);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_turnAddIn.mat',procList{dSet}{:}));
    save(saveName,'acc');
end 


