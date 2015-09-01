%saveFolder
saveFolder = 'D:\DATA\Analyzed Data\150805_overlapSelectivityAll';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
    
    %cluster
    [mMat,cMat,clusterIDs,clusterCenters]=getClusteredMarkovMatrix(imTrials);
    
    %find whichAct
    [~,whichAct] = calculateClusterOverlap(imTrials,clusterIDs,cMat);
    
    %get info 
    out = getOverlapSelectivityInfo(imTrials, whichAct);
    allOutInd(dSet) = out;
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_overlapSelectivity.mat',procList{dSet}{:}));
    save(saveName,'out');
end

%save
save(fullfile(saveFolder,'overlapSelectivity_allMice'),'allOut');

%% cat 
saveFolder = 'D:\DATA\Analyzed Data\150805_overlapSelectivityAll';

fields = fieldnames(allOutInd);
allOut = [];
for field = 1:length(fields)
    allOut.(fields{field}) = cat(1,allOutInd(:).(fields{field}));
end

%save 
save(fullfile(saveFolder,'overlapSelectivity_allMice'),'allOut','allOutInd');