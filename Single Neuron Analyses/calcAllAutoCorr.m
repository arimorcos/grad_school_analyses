%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151026_voegl_autoCorr_allNeurons';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
allAutoCorr = [];
windowSize = 210;
frameRate = 30;

for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    dataCell = loadProcessed(procList{dSet}{:},{'dataCell'},'vogel_noSmooth');
    
    %filter
    dataCell = filterROIGroups(dataCell,[1]);
    
    %get autocorr
    autoCorr = getCompleteAutoCorr(dataCell,true,windowSize);
    
    %cat
    allAutoCorr = cat(1,allAutoCorr,autoCorr);
    
    %save
    saveName = fullfile(saveFolder,sprintf(...
        '%s_%s_autoCorr_deconv_window_%d.mat',...
        procList{dSet}{:}, windowSize));
    save(saveName,'windowSize','frameRate','autoCorr');
    
end

% save
save(fullfile(saveFolder,sprintf('autoCorr_all_window_%d',windowSize)),...
    'allAutoCorr','frameRate','windowSize');