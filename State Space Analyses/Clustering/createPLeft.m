%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150716_deltaPLeftOneClustering';

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
    [~,~,clusterIDs,~] = getClusteredMarkovMatrix(imTrials,'oneClustering',true);
    
    %get deltaPLeft 
    [deltaPLeft,startPLeft,startNetEv] = calcPLeftChange(clusterIDs,imTrials);
    
    %get shuffled deltaPLeft
    deltaPLeftShuffle = nan(size(deltaPLeft,1),size(deltaPLeft,2),nShuffles);
    startPLeftShuffle = nan(size(deltaPLeftShuffle));
    startNetEvShuffle = nan(size(deltaPLeftShuffle));
    for shuffleInd = 1:nShuffles
        %shuffle clusterIDs
        shuffleIDs = nan(size(clusterIDs));
        for point = 1:size(clusterIDs,2)
            shuffleIDs(:,point) = shuffleArray(clusterIDs(:,point));
        end         

        [deltaPLeftShuffle(:,:,shuffleInd),startPLeftShuffle(:,:,shuffleInd),...
            startNetEvShuffle(:,:,shuffleInd)] = calcPLeftChange(shuffleIDs,imTrials);
    end
    
    %get netEvidence 
    netEvidence = getNetEvidence(imTrials);
    
    %get mazePatterns
    mazePattern = getMazePatterns(imTrials);
    
    %get segWeights 
    [segWeights, confInt] = getSegWeights(imTrials);
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_deltaPLeftOneClustering.mat',procList{dSet}{:}));
    save(saveName,'deltaPLeft','netEvidence','segWeights','confInt',...
        'startPLeft','mazePattern','startNetEv','deltaPLeftShuffle',...
        'startPLeftShuffle','startNetEvShuffle');
end