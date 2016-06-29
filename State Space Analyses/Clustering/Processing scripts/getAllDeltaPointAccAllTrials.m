%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/160310_vogel_all_trials_deltapoint_acc';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
% perc = [1 10 30 50 70];
perc = [10];

%get deltaPLeft
for dSet = 1:nDataSets
    for percVal = perc
        % for dSet = 7
        %dispProgress
        dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
        
        %load in data
        loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
        
        %get deconv all
        [~,~,deltaPoint,nUnique] = calcTrajPredictabilityAllTrials(imTrials,...
            'traceType','deconv','perc',percVal);
        
        %save
        saveName = fullfile(saveFolder,sprintf(...
            '%s_%s_deltaPoint_all_deconv.mat',...
            procList{dSet}{:}));
        save(saveName,'deltaPoint','nUnique');
    end
end

