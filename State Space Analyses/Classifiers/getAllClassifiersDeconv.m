%saveFolder
saveFolder = 'D:\DATA\Analyzed Data\150824_oldDeconv_smooth10_SVM';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
nShuffles = 100;
cParam = 4.4;
gamma = 0.04;

%get deltaPLeft
for dSet = 1:nDataSets
% for dSet = 8
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %get traces 
    traces = catBinnedDeconvTraces(imTrials);
    yPosBins = imTrials{1}.imaging.yPosBins;
    
    %% prevTurn
    %get real class
    prevTurn = getCellVals(imTrials,'result.prevTurn');
    
    % classify
    [accuracy,shuffleAccuracy] = classifyAndShuffle(traces,prevTurn,{'accuracy','shuffleAccuracy'},...
        'nshuffles',nShuffles,'C',cParam,'gamma',gamma);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_prevTurn.mat',procList{dSet}{:}));
    save(saveName,'accuracy','shuffleAccuracy','yPosBins');
    
    %% prev reward
    
    %get real class
    prevCorrect = getCellVals(imTrials,'result.prevCorrect');
    
    % classify
    [accuracy,shuffleAccuracy] = classifyAndShuffle(traces,prevCorrect,{'accuracy','shuffleAccuracy'},...
        'nshuffles',nShuffles,'C',cParam,'gamma',gamma);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_prevCorrect.mat',procList{dSet}{:}));
    save(saveName,'accuracy','shuffleAccuracy','yPosBins');
    
    %% upcoming turn
    
    %get real class
%     leftTurns = getCellVals(imTrials,'result.leftTurn');
% %     leftTurns = getCellVals(getTrials(imTrials,'maze.numLeft==1,2,3,4,5'),'result.leftTurn');
%     
% %     traces = catBinnedDeconvTraces(getTrials(imTrials,'maze.numLeft==1,2,3,4,5'));
%     
%     % classify
%     [accuracy,shuffleAccuracy] = classifyAndShuffle(traces,leftTurns,{'accuracy','shuffleAccuracy'},...
%         'nshuffles',nShuffles,'C',cParam,'gamma',gamma);
%     
%     %save
%     saveName = fullfile(saveFolder,sprintf('%s_%s_upcomingTurn.mat',procList{dSet}{:}));
%     save(saveName,'accuracy','shuffleAccuracy','yPosBins');
    
    %% net evidence 
%     classifierOut = classifyNetEvGroupSegSVM(imTrials,'nShuffles',nShuffles,...
%         'traceType','deconv');
%     
%     saveName = fullfile(saveFolder,sprintf('%s_%s_netEvSVR.mat',procList{dSet}{:}));
%     save(saveName,'classifierOut');
end