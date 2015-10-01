%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150907_vogel_deconv_selInd_seq';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);
nShuffles = 1000;

netEvIndAll = [];
shuffleNetEvIndAll = [];

for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
    
    %get sequence info 
    netEvIndAll = cat(1,netEvIndAll,getNetEvidenceSelectivity(imTrials));
    temp = [];
    for shuffleInd = 1:nShuffles
        temp(:,shuffleInd) = getNetEvidenceSelectivity(imTrials,true);
    end
    shuffleNetEvIndAll = cat(1,shuffleNetEvIndAll,temp);
   
    
end

% save 
save(fullfile(saveFolder,'netEvIndAllMice'),'netEvIndAll','shuffleNetEvIndAll');