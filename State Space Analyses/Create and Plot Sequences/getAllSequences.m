%saveFolder 
saveFolder = '/Users/arimorcos/Data/Analyzed Data/160222_vogel_new_seq';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
%     imTrials = binFramesByYPos(imTrials, 25);
    
    %get sequence info 
    [~,seqInfoCellNorm{dSet}] = makeLeftRightSeq(imTrials,'cells',{''});
    [~,seqInfoZScore{dSet}] = makeLeftRightSeq(imTrials,'zScore',{''});
    [~,seqInfoNoNorm{dSet}] = makeLeftRightSeq(imTrials,false,{''});
   
    
end

% save 
save('sequenceInfoAllMice','seqInfoCellNorm','seqInfoZScore','seqInfoNoNorm');