useZThresh = [0.3];

%saveFolder
saveFolder = '/mnt/7A08079708075215/DATA/Analyzed Data/160217_vogel_thresh_overlap';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
minClusterSize = [15:30];

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    sub = correctRight60;
    
    [~,cMatLeft,clusterIDsLeft,~]=getClusteredMarkovMatrix(correctLeft60,'traceType','deconv');
    [~,cMatRight,clusterIDsRight,~]=getClusteredMarkovMatrix(correctRight60,'traceType','deconv');
    
    for thresh = 1:length(useZThresh)
        for size = 1:length(minClusterSize)
            meanOverlap = showClusterOverlap(correctLeft60,clusterIDsLeft,cMatLeft,...
                'zThresh',useZThresh(thresh),'minClusterSize',minClusterSize(size),'nshuffles',5);
            
            saveName = fullfile(saveFolder,sprintf('%s_%s_left_shuffleCell_z%.1f_minCluster_%d.mat',...
                procList{dSet}{:},useZThresh(thresh),minClusterSize(size)));
            save(saveName,'meanOverlap');
            
            meanOverlap = showClusterOverlap(correctRight60,clusterIDsRight,cMatRight,...
                'zThresh',useZThresh(thresh),'minClusterSize',minClusterSize(size),'nshuffles',5);
            saveName = fullfile(saveFolder,sprintf('%s_%s_right_shuffleCell_z%.1f_minCluster_%d.mat',...
                procList{dSet}{:},useZThresh(thresh),minClusterSize(size)));
            save(saveName,'meanOverlap');
        end
        
        %save
        
    end
end

