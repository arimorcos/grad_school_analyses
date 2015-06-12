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
    [leftTrials,rightTrials] = loadProcessed(procList{mouseInd}{:},{'leftTrials','rightTrials'});
    
    %predict error
    [handles,errorMat{mouseInd}] = predictError({leftTrials, rightTrials},...
        'clusterperc', clusterPerc, 'handles', handles, 'showNTrials',...
        false, 'showPValue', false);
   
end