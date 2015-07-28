%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150722_offsetSVM';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

offsets = 0:0.25:4;

%get deltaPLeft
for dSet = 1:nDataSets
% for dSet = 7
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
    
    %initialize
    accuracy = cell(length(offsets),1);
    shuffleAccuracy = cell(length(offsets),1);
    
    for offset = 1:length(offsets)
        [accuracy{offset}, shuffleAccuracy{offset}] = offsetPrevCorrectSVM(imTrials, offsets(offset));       
    end
    
    %get yPosBins
    yPosBins = imTrials{1}.imaging.yPosBins;
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_offsetPrevCorrectSVM.mat',procList{dSet}{:}));
    save(saveName,'accuracy','shuffleAccuracy','yPosBins','offsets');
end 