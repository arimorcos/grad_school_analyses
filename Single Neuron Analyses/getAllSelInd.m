
%saveFolder 
saveFolder = '/mnt/7A08079708075215/DATA/Analyzed Data/160616_vogel_sel_ind_epsilon';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);
nShuffles = 1;

for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'vogel_noSmooth');
    
    %get sequence info 
    selIndAll{dSet} = getSelectivityIndex(imTrials);
    for shuffleInd = 1:nShuffles
        shuffleSelIndAll{dSet,shuffleInd} = getSelectivityIndex(imTrials,true);
    end
   
    
end

% save 
save(fullfile(saveFolder,'selIndAll_eps_0.5'),'selIndAll','shuffleSelIndAll');