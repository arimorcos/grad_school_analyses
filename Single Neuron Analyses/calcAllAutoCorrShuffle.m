%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151026_voegl_autoCorr_allNeurons_shuffle';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
allAutoCorr = [];
allAutoCorrShuffle = [];
windowSize = 1;
frameRate = 30;

% for dSet = 1:nDataSets
for dSet = 3    
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    dataCell = loadProcessed(procList{dSet}{:},{'dataCell'},'vogel_noSmooth');
    
    %filter
    dataCell = filterROIGroups(dataCell,[1]);
    
    %get autocorr
    [autoCorr,shuffleAutoCorr] = getCompleteAutoCorr(dataCell,true,windowSize,true);
    
    %cat
    allAutoCorr = cat(1,allAutoCorr,autoCorr);
    allAutoCorrShuffle = cat(1,allAutoCorrShuffle,shuffleAutoCorr);
    
    %save
    saveName = fullfile(saveFolder,sprintf(...
        '%s_%s_autoCorr_deconv_shuffle.mat',...
        procList{dSet}{:}));
    save(saveName,'windowSize','frameRate','autoCorr','allAutoCorrShuffle');
    
end

% save
save(fullfile(saveFolder,sprintf('autoCorr_all_window_%d',windowSize)),...
    'allAutoCorr','allAutoCorrShuffle','frameRate','windowSize');