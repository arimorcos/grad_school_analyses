%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150907_vogel_addIns\RED';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);


%get deltaPLeft
% for dSet = 1:nDataSets
for dSet = 7
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'deconv_vogel_RED');
    
    %get sort order 
    loadStr = sprintf('D:\\DATA\\Analyzed Data\\150906_singleNeuronSVM_vogel\\%s_%s_netEVSVR_deconv.mat',procList{dSet}{:});
    load(loadStr);
    netEvInd = cellfun(@getNetEvCorrCoef,classifierOut);
    [~,sortOrder] = sort(netEvInd);
    
    %get classifier out for addin 
    classifierOut = getNetEvidenceNeuronAddIn(imTrials,sortOrder);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_netEvAddIn_RED.mat',procList{dSet}{:}));
    save(saveName,'classifierOut');
end 