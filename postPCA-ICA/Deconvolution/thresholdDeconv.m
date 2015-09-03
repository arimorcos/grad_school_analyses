%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

span = 10;
saveDir = sprintf('W:\\Mice\\Foopsi_fudge_99\\thresholded_0_01',span);
if ~exist(saveDir)
    mkdir(saveDir);
end

thresh = 0.01;

%get deltaPLeft
for dSet = 1:nDataSets
    
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    dataCell = loadProcessed(procList{dSet}{:},{'dataCell'},'Foopsi_fudge_99');
    
    %add in previous result field
    dataCell = addPrevTrialResult(dataCell);
    
    %get traces
    deconvTrace = dataCell{1}.imaging.completeDeconvTrace;
    
    %threshold 
    for neuron = 1:size(deconvTrace,1)
        deconvTrace(neuron,:) = deconvTrace(neuron,deconvTrace(neuron,:) > thresh);
    end
    
    %add back to dataCell
    dataCell = standaloneCopyDeconvToDataCell(dataCell, deconvTrace);
    
    %filter roiGroups
    dataCell = filterROIGroups(dataCell,1);
    
    %save to processed
    imTrials = getTrials(dataCell,'maze.crutchTrial==0;imaging.imData==1');
    imTrials = imTrials(~findTurnAroundTrials(imTrials));
    imTrials = binFramesByYPos(imTrials,5);
    saveName = sprintf('%s_%s_processed.mat',procList{dSet}{1},procList{dSet}{2});
    save(fullfile(saveDir,saveName),'dataCell','imTrials');
end