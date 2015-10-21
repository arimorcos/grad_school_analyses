%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151020_vogel_arossEpochCluster';

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
    [overlapIndex,clusterCorr,transMat,deltaEpochs] =calcClusterOverlapCorrAcrossEpochs(correctLeft60,clusterIDs,cMat);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_acrossEpochCluster.mat',...
        procList{dSet}{:}));
    save(saveName,'overlapIndex','clusterCorr','transMat','deltaEpochs');
end

