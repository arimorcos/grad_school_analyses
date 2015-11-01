%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151026_vogel_autoCorr_sig';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
lag = 1*30; % in seconds

shufflePath = '/Users/arimorcos/Data/Analyzed Data/151026_voegl_autoCorr_allNeurons_shuffle';
realPath = '/Users/arimorcos/Data/Analyzed Data/151026_voegl_autoCorr_allNeurons';

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %load sig 
    load(fullfile(shufflePath,...
        sprintf('%s_%s_autoCorr_deconv_shuffle.mat',procList{dSet}{:})));
    
    %crop shuffle 
    autoCorrShuffle = squeeze(allAutoCorrShuffle(:,1,:));
    
    %load real autoCorr
    load(fullfile(realPath,...
        sprintf('%s_%s_autoCorr_deconv_window_210.mat',procList{dSet}{:})));
    
    %get actual autoCorr 
    winSize = ceil(size(autoCorr,2)/2);
    realVal = autoCorr(:,winSize + lag);
    
    %get pVals 
    nNeurons = length(realVal);
    pVal = nan(nNeurons,1);
    for neuron = 1:nNeurons
        pVal(neuron) = getPValFromShuffle(realVal(neuron),...
            autoCorrShuffle(neuron,:));
    end
    notSig = find(pVal > 0.05);
    
    %get deconv all
    [~,~,deltaPoint,nUnique] = calcTrajPredictabilityUnified(imTrials,...
        'traceType','deconv','whichNeurons',notSig);
    
    %save
    saveName = fullfile(saveFolder,sprintf(...
        '%s_%s_deltaPoint_all_deconv_lag_%d_autocorr_sig.mat',...
        procList{dSet}{:}, lag/30));
    save(saveName,'deltaPoint','nUnique');
end