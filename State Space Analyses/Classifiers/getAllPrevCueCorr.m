%saveFolder 
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151008_prevCueCorr/Controlled prevTurn';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

controlPrevTurn = true;
intraOnlyPrevTurn = false;

%get deltaPLeft
for dSet = 1:nDataSets
% for dSet = 7
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    
    %% cosine
    % get prevCueCorr
    out = calcPrevCueCorr(imTrials,'useCosine',true, ...
        'controlPrevTurn', controlPrevTurn, 'intraOnlyPrevTurn',intraOnlyPrevTurn);
    
    %save 
    saveName = fullfile(saveFolder,sprintf(....
        '%s_%s_prevCueCosine.mat',procList{dSet}{:}));
    save(saveName,'out');
    
    
    %% corr 
    % get prevCueCorr
    out = calcPrevCueCorr(imTrials,'useCosine',false, ...
        'controlPrevTurn',controlPrevTurn,'intraOnlyPrevTurn', intraOnlyPrevTurn);
    
    %save 
    saveName = fullfile(saveFolder,sprintf(....
        '%s_%s_prevCueCorr.mat',procList{dSet}{:}));
    save(saveName,'out');
end 