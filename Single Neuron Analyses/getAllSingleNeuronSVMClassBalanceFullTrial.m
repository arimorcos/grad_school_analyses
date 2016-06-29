%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/160626_vogel_svm_classbal_fulltrial_allshuffle';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
% nDataSets = 1;
num_shuffles = 1000;

%get deltaPLeft
for dSet = 3:nDataSets
    % for dSet = 7
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    sub = trials60;
    
    %remap to large bin sizes 
    sub_fifths = sub;
    sub_fifths = binFramesByYPos(sub_fifths, 100);
    
    %get traces
    deconvTraces = catBinnedDeconvTraces(sub_fifths);
    yPosBins = sub_fifths{1}.imaging.yPosBins;
    
    [nNeurons,nBins,~] = size(deconvTraces);
    
    
%     %% upcoming turn deconv fifths
%     
%     %get real class
%     leftTurns = getCellVals(sub_fifths,'result.leftTurn');
%     
%     %class balance 
%     num_trials = length(leftTurns);
%     num_left = sum(leftTurns);
%     num_right = num_trials - num_left;
%     if num_left < num_right
%         keep_ind = find(leftTurns == 1);
%         right_ind = shuffleArray(find(leftTurns == 0));
%         keep_ind = sort(cat(2, keep_ind, right_ind(1:num_left)));
%         leftTurns = leftTurns(keep_ind);
%         deconvTraces = deconvTraces(:, :, keep_ind);
%     elseif num_right < num_left
%         keep_ind = find(leftTurns == 0);
%         left_ind = shuffleArray(find(leftTurns == 1));
%         keep_ind = sort(cat(2, keep_ind, left_ind(1:num_right)));
%         leftTurns = leftTurns(keep_ind);
%         deconvTraces = deconvTraces(:, :, keep_ind);
%     end
%     
%     %initialize
%     accuracy = nan(nNeurons,nBins);
%     shuffleAccuracy = nan(nNeurons, nBins);
%     
%     for neuronInd = 1:nNeurons
%         % classify
%         accuracy(neuronInd,:) = getSVMAccuracy(...
%             deconvTraces(neuronInd,:,:),...
%             leftTurns, 'leaveOneOut', true,...
%             'kernel', 'linear', 'cParam', 10);
%         shuffleAccuracy(neuronInd,:) = getSVMAccuracy(...
%             deconvTraces(neuronInd,:,:),...
%             shuffleArray(leftTurns), 'leaveOneOut', true,...
%             'kernel', 'linear', 'cParam', 10);
%     end
%     
%     %save
%     saveName = fullfile(saveFolder,...
%         sprintf('%s_%s_upcomingTurn_deconv_fifthbins.mat',procList{dSet}{:}));
%     save(saveName,'accuracy','shuffleAccuracy','yPosBins');
    
    %% upcoming turn deconv fifths
    
    deconvTraces = catBinnedDeconvTraces(sub);
    deconvTraces = nanmean(deconvTraces, 2);
    
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
    accuracy = nan(nNeurons,1);
    shuffleAccuracy = nan(nNeurons, num_shuffles);
    
    for neuronInd = 1:nNeurons
        % classify
        accuracy(neuronInd) = getSVMAccuracy(...
            deconvTraces(neuronInd,:,:),...
            leftTurns, 'leaveOneOut', true,...
            'kernel', 'linear', 'cParam', 10);
        for shuffle_ind = 1:num_shuffles
            shuffleAccuracy(neuronInd, shuffle_ind) = getSVMAccuracy(...
                deconvTraces(neuronInd,:,:),...
                shuffleArray(leftTurns), 'leaveOneOut', true,...
                'kernel', 'linear', 'cParam', 10);
        end
    end
    
    %save
    saveName = fullfile(saveFolder,...
        sprintf('%s_%s_upcomingTurn_deconv_fulltrial.mat',procList{dSet}{:}));
    save(saveName,'accuracy','shuffleAccuracy','yPosBins');
end