%%
%saveFolder
saveFolder = 'D:\DATA\Analyzed Data\150908_vogel_first4Same';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
% 
% %get deltaPLeft
% for dSet = 1:nDataSets
%     %dispProgress
%     dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
%     
%     %load in data
%     loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
%     
%     %get first4Same
%     first4Left = getTrials(imTrials,'[1 1 1 1 NaN NaN]');
%     first4Right = getTrials(imTrials,'[0 0 0 0 NaN NaN]');
%     first4Same = cat(2,first4Left,first4Right);
%     
%     %get error rate
%     nErrors = sum(findTrials(first4Same,'result.correct==0'));
%     nTrials = length(first4Same);
%     errorRate = nErrors/nTrials;
%     
%     %cluster and calculatemjnm     mm m                m
%     [mMat,cMat,clusterIDs,clusterCenters] = getClusteredMarkovMatrix(first4Same,'perc',50);
%     [probIncorrect,pVal] = calcHighwayCorrect(clusterIDs,first4Same,5,10);
%     
%     %save
%     saveName = fullfile(saveFolder,sprintf('%s_%s_highwayCorrect_first4_perc50.mat',procList{dSet}{:}));
%     save(saveName,'probIncorrect','pVal','errorRate','nErrors','nTrials');
%     
% %     %cluster and calculate
% %     [mMat,cMat,clusterIDs,clusterCenters] = getClusteredMarkovMatrix(first4Same,'perc',2);
% %     [probIncorrect,pVal] = calcHighwayCorrect(clusterIDs,first4Same,5,10);
% %     
% %     %save
% %     saveName = fullfile(saveFolder,sprintf('%s_%s_highwayCorrect.mat',procList{dSet}{:}));
% %     save(saveName,'probIncorrect','pVal');
% %     
% %     %cluster and calculate
% %     [mMat,cMat,clusterIDs,clusterCenters] = getClusteredMarkovMatrix(first4Right,'perc',2);
% %     [probIncorrect,pVal] = calcHighwayCorrect(clusterIDs,first4Right,5,10);
% %     
% %     %save
% %     saveName = fullfile(saveFolder,sprintf('%s_%s_highwayCorrect_right.mat',procList{dSet}{:}));
% %     save(saveName,'probIncorrect','pVal');
% %     
% %     %cluster and calculate
% %     [mMat,cMat,clusterIDs,clusterCenters] = getClusteredMarkovMatrix(first4Left,'perc',2);
% %     [probIncorrect,pVal] = calcHighwayCorrect(clusterIDs,first4Left,5,10);
% %     
% %     %save
% %     saveName = fullfile(saveFolder,sprintf('%s_%s_highwayCorrect_left.mat',procList{dSet}{:}));
% %     save(saveName,'probIncorrect','pVal');
% end

%% grid search
firstPerc = [1, 10, 30, 50, 70];
secondPerc = [1, 10, 50];
pVal = nan(length(firstPerc),length(secondPerc),nDataSets);
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %get first4Same
    first4Left = getTrials(imTrials,'[1 1 1 1 NaN NaN]');
    first4Right = getTrials(imTrials,'[0 0 0 0 NaN NaN]');
    first4Same = cat(2,first4Left,first4Right);
    
    %get error rate
    errorRate(dSet) = sum(findTrials(first4Same,'result.correct==0'))/length(first4Same);
    
    %cluster and calculate
    for firstInd = 1:length(firstPerc)
        [mMat,cMat,clusterIDs,clusterCenters] = getClusteredMarkovMatrix(first4Same,'perc',firstPerc(firstInd));
        parfor secondInd = 1:length(secondPerc)
            [~,pVal(firstInd,secondInd,dSet)] = calcHighwayCorrect(clusterIDs,first4Same,5,secondPerc(secondInd));
        end
    end
end

%save
saveName = fullfile(saveFolder,sprintf('pValGridSearch_first4_smooth10.mat',procList{dSet}{:}));
save(saveName,'pVal','errorRate');