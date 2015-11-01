%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/150910_vogel_viewAngleSVR';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

viewRange = 5;

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %view angle classifiers
    leftClassifierOut = classifyNetEvGroupSegSVM(imTrials,...
        'binViewAngle',true,'leftViewAngle',true,'viewAngleRange',viewRange);
    rightClassifierOut = classifyNetEvGroupSegSVM(imTrials,...
        'binViewAngle',true,'leftViewAngle',false,'viewAngleRange',viewRange);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_leftViewAngle_range%d.mat',procList{dSet}{:},viewRange));
    save(saveName,'leftClassifierOut');
    saveName = fullfile(saveFolder,sprintf('%s_%s_rightViewAngle_range%d.mat',procList{dSet}{:},viewRange));
    save(saveName,'rightClassifierOut');
end