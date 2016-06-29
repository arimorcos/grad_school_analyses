
%saveFolder 
saveFolder = '/mnt/7A08079708075215/DATA/Analyzed Data/160616_vogel_sel_ind_new';

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
    selIndAll{dSet} = getSelectivityIndexFullTrial(imTrials);
   for shuffleInd = 1:nShuffles
        shuffleSelIndAll{dSet,shuffleInd} = getSelectivityIndexFullTrial(imTrials,true);
    end
    
end

selIndAllNeurons = cat(1, selIndAll{:});
shuffleSelIndAllNeurons = cat(1, shuffleSelIndAll{:});

% save 
save(fullfile(saveFolder,'selIndAll_vogel'),'selIndAll', 'selIndAllNeurons',...
    'shuffleSelIndAll', 'shuffleSelIndAllNeurons');