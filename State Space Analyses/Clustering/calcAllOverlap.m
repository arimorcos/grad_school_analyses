useZThresh = 1;

%saveFolder
saveFolder = 'D:\DATA\Analyzed Data\150802_overlapAll';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
    
    [~,cMat,clusterIDs,~]=getClusteredMarkovMatrix(left60);
    meanOverlap = showClusterOverlap(left60,clusterIDs,cMat,'zThresh',useZThresh);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_OverlapIndex_shuffleCell_z%.1f.mat',...
        procList{dSet}{:},useZThresh));
    save(saveName,'meanOverlap');
end

