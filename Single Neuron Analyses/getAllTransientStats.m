%
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151013_vogel_transStats';

% get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'vogel_noSmooth');

    %process
%     stats = getTransientStats(imTrials,'traceType','deconv',...
%         'limitToSeg',true);
    stats = getSimpleTransStats(imTrials);
    allStats{dSet} = stats;
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_transStats.mat',procList{dSet}{:}));
    save(saveName,'stats');
    
end

%% concatenate and save 

tempMeanFracActive = cellfun(@(x) x.meanFracActive, allStats, 'uniformOutput',false);
stats.meanFracActive = cat(1,tempMeanFracActive{:});

tempSTDFracActive = cellfun(@(x) x.stdFracActive, allStats, 'uniformOutput',false);
stats.stdFracActive = cat(1,tempSTDFracActive{:});

tempMeanFracCueActive = cellfun(@(x) x.meanFracCueActive, allStats, 'uniformOutput',false);
stats.meanFracCueActive = cat(1,tempMeanFracCueActive{:});

tempSTDFracCueActive = cellfun(@(x) x.stdFracCueActive, allStats, 'uniformOutput',false);
stats.stdFracCueActive = cat(1,tempSTDFracCueActive{:});

save('allStats','stats');
