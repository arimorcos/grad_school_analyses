%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150907_vogel_deconv_selInd_seq';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);
nShuffles = 1000;

for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
    
    %get sequence info 
    selIndAll{dSet} = getSelectivityIndex(imTrials);
    for shuffleInd = 1:nShuffles
        shuffleSelIndAll{dSet,shuffleInd} = getSelectivityIndex(imTrials,true);
    end
   
    
end

% save 
save(fullfile(saveFolder,'selIndAll'),'selIndAll','shuffleSelIndAll');