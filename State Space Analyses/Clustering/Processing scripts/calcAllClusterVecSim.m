
%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151022_vogel_clusterVecSim';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    [~,cMat,clusterIDs,~]=getClusteredMarkovMatrix(correctLeft60,'traceType','deconv');
    meanVecSim = showClusterVecSim(correctLeft60,clusterIDs,cMat,...
        'meanSubtract',false);
    
    %save
    saveName = fullfile(saveFolder,sprintf(...
        '%s_%s_vecSim_correct_shuffleCell_deconv.mat',...
        procList{dSet}{:}));
    save(saveName,'meanVecSim');
end

