%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150910_vogel_firstSegAcc';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
% for dSet = 7
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %get traces 
    yPosBins = imTrials{1}.imaging.yPosBins;
    firstSegInd = yPosBins >= 0 & yPosBins < 80;
    yPosBins = yPosBins(firstSegInd);
%     [~,traces] = catBinnedTraces(imTrials);
    traces = catBinnedDeconvTraces(imTrials);
    traces = traces(:,firstSegInd,:);
    
    %get realClass
    mazePatterns = getMazePatterns(imTrials);
    realClass = mazePatterns(:,1);
    
    %get accuracy 
    [accuracy,shuffleAccuracy] = classifyAndShuffle(traces,realClass,{'accuracy','shuffleAccuracy'},'nshuffles',100);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_firstSeg.mat',procList{dSet}{:}));
    save(saveName,'accuracy','shuffleAccuracy','yPosBins');
end 