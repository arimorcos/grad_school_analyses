%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151023_dff_binarize_deltaPointAcc';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
% perc = [1 10 30 50 70];
perc = [10];

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %get deconv all
    try
        [~,~,deltaPoint,nUnique] = calcTrajPredictabilityUnified(imTrials,...
            'traceType','dFF','binarize',true,'binarizeThresh',1);
        
        %save
        saveName = fullfile(saveFolder,sprintf(...
            '%s_%s_deltaPoint_binarized_thresh_%d.mat',...
            procList{dSet}{:}, 1));
        save(saveName,'deltaPoint','nUnique');
    catch
    end
end
