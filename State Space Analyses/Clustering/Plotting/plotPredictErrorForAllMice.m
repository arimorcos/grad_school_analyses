function errorMat = plotPredictErrorForAllMice(clusterPerc)
%plotPredictErrorForAllMice.m Plots predict error for all the mice

if nargin < 1 || isempty(clusterPerc)
    clusterPerc = 30;
end

%get mice
procList = getProcessedList();

%loop through, load and create 
nMice = length(procList);
handles = [];
errorMat = cell(nMice,1);
for mouseInd = 1:nMice 
    %load
    [leftTrials,rightTrials] = loadProcessed(procList{mouseInd}{:},...
        {'leftTrials','rightTrials'},'oldDeconv_smooth10');
    
    %predict error
    [handles,errorMat{mouseInd},out] = predictError({leftTrials, rightTrials},...
        'clusterperc', clusterPerc, 'handles', handles, 'showNTrials',...
        false, 'showPValue', false,'tracetype','dFF');
    
    %save 
%     saveFolder = '/Users/arimorcos/Data/Analyzed Data/150908_vogel_first4Same';
    saveFolder = '/Users/arimorcos/Data/Analyzed Data/151015_predictError_dFF';
    saveName = fullfile(saveFolder,sprintf('%s_%s_mazeStartError.mat',procList{mouseInd}{:}));
    save(saveName,'out');
   
end