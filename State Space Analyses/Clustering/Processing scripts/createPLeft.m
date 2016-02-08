%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150811_allPLeft';

%nShuffles 
nShuffles = 100;

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
    [~,~,clusterIDs,~] = getClusteredMarkovMatrix(imTrials,'oneClustering',false);
    
    %get deltaPLeft 
    out = calcPLeftChange(clusterIDs,imTrials);
    
    %get shuffled deltaPLeft
    shuffleOut = cell(nShuffles,1);
    for shuffleInd = 1:nShuffles
        %shuffle clusterIDs
        shuffleIDs = nan(size(clusterIDs));
        for point = 1:size(clusterIDs,2)
            shuffleIDs(:,point) = shuffleArray(clusterIDs(:,point));
        end         

        shuffleOut{shuffleInd} = calcPLeftChange(shuffleIDs,imTrials);
    end
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_deltaPLeftAllVar.mat',procList{dSet}{:}));
    save(saveName,'out','shuffleOut');
end