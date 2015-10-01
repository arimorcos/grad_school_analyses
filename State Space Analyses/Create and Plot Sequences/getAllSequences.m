%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150907_vogel_deconv_selInd_seq';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
    
    %get sequence info 
    [~,seqInfoCellNorm{dSet}] = makeLeftRightSeq(imTrials,'cells',{''});
    [~,seqInfoZScore{dSet}] = makeLeftRightSeq(imTrials,'zScore',{''});
    [~,seqInfoNoNorm{dSet}] = makeLeftRightSeq(imTrials,false,{''});
   
    
end

% save 
save('sequenceInfoAllMice','seqInfoCellNorm','seqInfoZScore','seqInfoNoNorm');