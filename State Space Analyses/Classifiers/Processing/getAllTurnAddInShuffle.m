%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150925_vogel_shuffleAddINs';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);


%get deltaPLeft
for dSet = 1:nDataSets
% for dSet = 8
    %dispProgress
%     dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %get traces
    traces = catBinnedDeconvTraces(imTrials);
    traces = traces(:,80:end-5,:);
    [nNeurons,nBins,~] = size(traces);
    
    %shuffle trial ids
    leftTurns = getCellVals(imTrials,'result.leftTurn');
    shuffleTurns = shuffleArray(leftTurns);
    
    %get accuracy 
    accuracy = nan(nNeurons,nBins);
    parfor neuronInd = 1:nNeurons
        accuracy(neuronInd,:) = getSVMAccuracy(traces,shuffleTurns,'kFold',...
            1);
        fprintf('Dataset: %d/%d, neuron: %d/%d\n',dSet,nDataSets,neuronInd,nNeurons);
    end
    singleNeuronAcc = accuracy;
    
    %get sort order 
    maxAcc = max(accuracy,[],2);
    [~,sortOrder] = sort(maxAcc);
    
    %get classifier out for addin 
    fprintf('Dataset: %d/%d, Performing add-in',dSet,nDataSets);
    acc = getLeftRightAccuracyNeuronFallout(imTrials, sortOrder, false, 20, shuffleTurns);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_turnAddIn_shuffled.mat',procList{dSet}{:}));
    save(saveName,'acc','singleNeuronAcc','shuffleTurns');
end 


