useZThresh = [0.3 0.4];

%saveFolder
saveFolder = 'D:\DATA\Analyzed Data\150909_vogel_overlap_all';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    [~,cMat,clusterIDs,~]=getClusteredMarkovMatrix(left60,'traceType','deconv');
    
    for thresh = 1:length(useZThresh)
        meanOverlap = showClusterOverlap(left60,clusterIDs,cMat,'zThresh',useZThresh(thresh));
        
        %save
        saveName = fullfile(saveFolder,sprintf('%s_%s_OverlapIndex_shuffleCell_z%.1f.mat',...
            procList{dSet}{:},useZThresh(thresh)));
        save(saveName,'meanOverlap');
    end
end

