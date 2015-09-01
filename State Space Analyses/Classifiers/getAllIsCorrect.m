%saveFolder
saveFolder = 'D:\DATA\Analyzed Data\150827_svm_isCorrect';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 2:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %get traces
    traces = catBinnedDeconvTraces(imTrials);
    correct = getCellVals(imTrials,'result.correct');
    
    %% perform random search
    %subset
    nTrials = size(traces,3);
    nTrain = round(0.5*nTrials);
    nTest = nTrials - nTrain;
    trainSet = randsample(nTrials,nTrain);
    testSet = setdiff(1:nTrials,trainSet);
    trainTraces = traces(:,:,trainSet);
    testTraces = traces(:,:,testSet);
    
    trainCorrect = correct(trainSet);
    
    %get ranges
    cRange = [0 8];
    gammaRange = [1e-6 4];
    cOptions = linspace(cRange(1), cRange(2), 100);
    gammaOptions = linspace(gammaRange(1), gammaRange(2), 100);
    
    %loop through and generate parameters
    nIter = 1000;
    cParam = nan(nIter,1);
    gamma = nan(nIter,1);
    acc = nan(nIter,1);
    for i = 1:nIter
        
        %randomly generate parameters
        cParam(i) = cOptions(randi([1 100]));
        gamma(i) = gammaOptions(randi([1 100]));
        
        %get accuracy
        acc(i) = getSVMAccuracy(traces(:,4,trainSet),trainCorrect,'cParam',cParam(i),'gamma',gamma(i));
        
        dispProgress('%d/%d',i,i,nIter);
    end
    
    [~,ind] = max(acc);
    useC = cParam(ind);
    useGamma = gamma(ind);
    
    
    %% get actual answer
    realClass = correct;
    [accuracy,shuffleAccuracy] = classifyAndShuffle(traces,realClass,...
        {'accuracy','shuffleAccuracy'},'nshuffles',100,'cParam',useC,...
        'gamma',useGamma,'trainInd',trainSet);
    
    yPosBins = imTrials{1}.imaging.yPosBins;
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_isCorrect.mat',procList{dSet}{:}));
    save(saveName,'accuracy','shuffleAccuracy','yPosBins');
end