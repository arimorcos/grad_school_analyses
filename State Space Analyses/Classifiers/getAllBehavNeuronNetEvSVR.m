%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151030_vogel_behav_neuron_netEvSVR/Test';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %view angle classifiers
    behavClassifierOut = classifyNetEvGroupSegSVM(imTrials,...
        'useBehaviorOnly',true,'gamma',0.6,'epsilon',1);
    behavNeuronClassifierOut = classifyNetEvGroupSegSVM(imTrials,...
        'useBehaviorAndNeuron',true,'gamma',0.6,'epsilon',1);
%     neuronClassifierOut = classifyNetEvGroupSegSVM(imTrials,...
%         'gamma',0.2);
    neuronClassifierOut = [];
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_behavNeuronSVM.mat',procList{dSet}{:}));
    save(saveName,'behavClassifierOut','behavNeuronClassifierOut','neuronClassifierOut');
end