%saveFolder 
saveFolder = '/mnt/7A08079708075215/DATA/Analyzed Data/160201_vogel_addIn_netEv_breakCorr';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);


%get deltaPLeft
for dSet = 1:nDataSets
% for dSet = 8;
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %get sort order 
    loadStr = sprintf('/mnt/7A08079708075215/DATA/Analyzed Data/150906_singleNeuronSVM_vogel/%s_%s_netEvSVR_deconv.mat',procList{dSet}{:});
    load(loadStr);
    netEvInd = cellfun(@getNetEvCorrCoef,classifierOut);
    [~,sortOrder] = sort(netEvInd);
    
    %get classifier out for addin 
    classifierOut = getNetEvidenceNeuronAddIn(imTrials,sortOrder, [], [], false);
    classifierOutBreakCorr = getNetEvidenceNeuronAddIn(imTrials,sortOrder, [], [], true);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_netEvAddIn_breakCorr.mat',procList{dSet}{:}));
    save(saveName,'classifierOut', 'classifierOutBreakCorr');
end 


