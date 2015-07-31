%saveFolder 
saveFolder = 'D:\DATA\Analyzed Data\150730_deltaPointAcc_all';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
% for dSet = 7
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:});
    
    %get dff delta point
    [~,~,deltaPoint] = calcTrajPredictability(left60,'traceType','dff');
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_deltaPoint_left_dFF.mat',procList{dSet}{:}));
    save(saveName,'deltaPoint');
    
    %get dff deconv
    [~,~,deltaPoint] = calcTrajPredictability(left60,'traceType','deconv');
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_deltaPoint_left_deconv.mat',procList{dSet}{:}));
    save(saveName,'deltaPoint');
    
     %get dff delta point
    [~,~,deltaPoint] = calcTrajPredictability(right60,'traceType','dff');
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_deltaPoint_right_dFF.mat',procList{dSet}{:}));
    save(saveName,'deltaPoint');
    
    %get dff deconv
    [~,~,deltaPoint] = calcTrajPredictability(right60,'traceType','deconv');
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_deltaPoint_right_deconv.mat',procList{dSet}{:}));
    save(saveName,'deltaPoint');
end 