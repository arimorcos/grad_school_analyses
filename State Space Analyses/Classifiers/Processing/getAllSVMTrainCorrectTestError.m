%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/160312_vogel_choiceSVM_trainCorrect_testError';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
nShuffles = 100;
cParam = 4.4;
gamma = 0.04;

shouldPrevTurn = false;
shouldPrevCorrect = true;

whichSets = 1:nDataSets;

%get deltaPLeft
for dSet = 1:nDataSets
    
    if ~ismember(dSet,whichSets)
        continue;
    end
    
    % for dSet = 8
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %get traces
    traces = catBinnedDeconvTraces(imTrials);
    yPosBins = imTrials{1}.imaging.yPosBins;
    
    %get real class
    leftTurn = getCellVals(imTrials,'result.leftTurn');
    
    trainInd = find(findTrials(imTrials,'result.correct==1'));
    
    % classify
    accuracy = getSVMAccuracy(traces,leftTurn,'Cparam',cParam,'gamma',gamma, 'trainInd', trainInd);
    shuffleAccuracy = [];
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s.mat',procList{dSet}{:}));
    save(saveName,'accuracy','shuffleAccuracy','yPosBins');
    
end