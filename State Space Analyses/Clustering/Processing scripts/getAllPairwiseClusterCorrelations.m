%saveFolder
saveFolder = '/mnt/7A08079708075215/DATA/Analyzed Data/160218_vogel_pairwise_cluster_corr';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dat aset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %cluster
    [~, leftCMat, leftClusterIDs, ~] = getClusteredMarkovMatrix(correctLeft60);
    [~, rightCMat, rightClusterIDs, ~] = getClusteredMarkovMatrix(correctRight60);
    
    for point = 1:size(leftClusterIDs, 2)
        %get correct left 6-0
        [left_inter{point}, left_intra{point}] = ...
            getPairwiseClusterCorrelations(correctLeft60,leftClusterIDs,leftCMat,point);
        
        %get correct right 0-6
        [right_inter{point}, right_intra{point}] = ...
            getPairwiseClusterCorrelations(correctRight60,rightClusterIDs,rightCMat,point);
    end
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_clusterCorr.mat',procList{dSet}{:}));
    save(saveName,'left_inter', 'left_intra', 'right_inter', 'right_intra');
end