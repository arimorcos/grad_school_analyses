%saveFolder 
saveFolder = '/mnt/7A08079708075215/DATA/Analyzed Data/160125_vogel_addIn_breakCorr';

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
    loadStr = sprintf('/mnt/7A08079708075215/DATA/Analyzed Data/151013_vogel_singleNeuronSVMs_boot/%s_%s_upcomingTurn_deconv.mat',procList{dSet}{:});
    load(loadStr);
    maxAcc = max(accuracy,[],2);
    [~,sortOrder] = sort(maxAcc);
    
    %get classifier out for addin 
    increment = 1;
    acc = getLeftRightAccuracyNeuronFallout(trials60, sortOrder, false, increment);
    acc_break_corr = getLeftRightAccuracyNeuronFallout(trials60, sortOrder, true, increment);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_turnAddIn_breakCorr.mat',procList{dSet}{:}));
    save(saveName,'acc', 'acc_break_corr');
end 


