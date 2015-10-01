%saveFolder
saveFolder = 'D:\DATA\Analyzed Data\150925_vogel_singleNeuronSVM_crossval';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
nShuffles = 1;
kfold = 10;

%get deltaPLeft
for dSet = 1:nDataSets
    % for dSet = 7
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %get traces
    [~,traces] = catBinnedTraces(imTrials);
    deconvTraces = catBinnedDeconvTraces(imTrials);
    yPosBins = imTrials{1}.imaging.yPosBins;
    
    [nNeurons,nBins,~] = size(traces);
    
    
    %% upcoming turn dff
    
%     %get real class
    leftTurns = getCellVals(imTrials,'result.leftTurn');
%     
%     %initialize 
%     accuracy = nan(nNeurons,nBins);
%     shuffleAccuracy = nan(nShuffles,nBins,nNeurons);
%     
%     for neuronInd = 1:nNeurons
%         % classify
%         [accuracy(neuronInd,:),shuffleAccuracy(:,:,neuronInd)] = classifyAndShuffle(traces(neuronInd,:,:),...
%             leftTurns,{'accuracy','shuffleAccuracy'},...
%             'nshuffles',nShuffles,'silent',true);
%         
%         dispProgress('Upcoming turn dFF: neuron %d/%d',neuronInd,neuronInd,nNeurons);
%     end
%     
%     %save
%     saveName = fullfile(saveFolder,sprintf('%s_%s_upcomingTurn_dFF.mat',procList{dSet}{:}));
%     save(saveName,'accuracy','shuffleAccuracy','yPosBins');
    
    %% upcoming turn deconv
    
    %initialize 
    accuracy = nan(nNeurons,nBins);
    shuffleAccuracy = nan(nShuffles,nBins,nNeurons);
    
    for neuronInd = 1:nNeurons
        % classify
        [accuracy(neuronInd,:),shuffleAccuracy(:,:,neuronInd)] = classifyAndShuffle(deconvTraces(neuronInd,:,:),...
            leftTurns,{'accuracy','shuffleAccuracy'},...
            'nshuffles',nShuffles,'silent',true,'kfold',kfold);
        
        dispProgress('Upcoming turn deconv: neuron %d/%d',neuronInd,neuronInd,nNeurons);
    end
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_upcomingTurn_deconv.mat',procList{dSet}{:}));
    save(saveName,'accuracy','shuffleAccuracy','yPosBins');
    
    %% net evidence dFF
%     classifierOut = cell(nNeurons,1);
%     for neuronInd = 1:nNeurons
%         classifierOut{neuronInd} = classifyNetEvGroupSegSVM(imTrials,'nShuffles',nShuffles,...
%             'traceType','dff','whichNeurons',neuronInd,'shouldShuffle',true);
%         
%         dispProgress('Net evidence: neuron %d/%d',neuronInd,neuronInd,nNeurons);
%     end
%     
%     saveName = fullfile(saveFolder,sprintf('%s_%s_netEvSVR_dFF.mat',procList{dSet}{:}));
%     save(saveName,'classifierOut');
%     
    %% net evidence deconv
    classifierOut = cell(nNeurons,1);
    for neuronInd = 1:nNeurons
        classifierOut{neuronInd} = classifyNetEvGroupSegSVM(imTrials,'nShuffles',nShuffles,...
            'traceType','deconv','whichNeurons',neuronInd,'shouldShuffle',true,'kfold',kfold);
        
        dispProgress('Net evidence deconv: neuron %d/%d',neuronInd,neuronInd,nNeurons);
    end
    
    saveName = fullfile(saveFolder,sprintf('%s_%s_netEvSVR_deconv.mat',procList{dSet}{:}));
    save(saveName,'classifierOut');    
end