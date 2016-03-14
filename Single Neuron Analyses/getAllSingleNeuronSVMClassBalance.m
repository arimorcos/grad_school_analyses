%saveFolder
saveFolder = '/mnt/7A08079708075215/DATA/Analyzed Data/160216_vogel_single_neuron_SVM_classbalance';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
nShuffles = 1;
% nDataSets = 1;

%get deltaPLeft
for dSet = 1:nDataSets
    % for dSet = 7
    %dispProgress
    fprintf('Dataset %d/%d \n', dSet, nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    sub = trials60;
    sub = binFramesByYPos(sub, 50);
    
    %get traces
    deconvTraces = catBinnedDeconvTraces(sub);
    yPosBins = sub{1}.imaging.yPosBins;
    
    [nNeurons,nBins,~] = size(deconvTraces);
    
    
    %% upcoming turn deconv
    
    %get real class
    leftTurns = getCellVals(sub,'result.leftTurn');
    
    %class balance 
    num_trials = length(leftTurns);
    num_left = sum(leftTurns);
    num_right = num_trials - num_left;
    if num_left < num_right
        keep_ind = find(leftTurns == 1);
        right_ind = shuffleArray(find(leftTurns == 0));
        keep_ind = sort(cat(2, keep_ind, right_ind(1:num_left)));
        leftTurns = leftTurns(keep_ind);
        deconvTraces = deconvTraces(:, :, keep_ind);
    elseif num_right < num_left
        keep_ind = find(leftTurns == 0);
        left_ind = shuffleArray(find(leftTurns == 1));
        keep_ind = sort(cat(2, keep_ind, left_ind(1:num_right)));
        leftTurns = leftTurns(keep_ind);
        deconvTraces = deconvTraces(:, :, keep_ind);
    end
    
    %initialize
    accuracy = nan(nNeurons,nBins);
    shuffleAccuracy = nan(nShuffles, nNeurons, nBins);
    
    for neuronInd = 1:nNeurons
        % classify
        accuracy(neuronInd,:) = getSVMAccuracy(...
            deconvTraces(neuronInd,:,:),...
            leftTurns, 'leaveOneOut', false,...
            'kernel', 'rbf', 'kFold', 5);
        for shuffleInd = 1:nShuffles
            shuffleAccuracy(shuffleInd, neuronInd, :) = getSVMAccuracy(...
                deconvTraces(neuronInd,:,:),...
                shuffleArray(leftTurns), 'leaveOneOut', false,...
                'kernel', 'rbf', 'kFold', 5);
        end
        dispProgress('Neuron %d/%d', neuronInd, neuronInd, nNeurons);
    end
    shuffleAccuracy = squeeze(mean(shuffleAccuracy, 1));
    fprintf('\n');    
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_upcomingTurn_deconv.mat',procList{dSet}{:}));
    save(saveName,'accuracy','shuffleAccuracy','yPosBins');
end

getPeakAccuracyAndSig;