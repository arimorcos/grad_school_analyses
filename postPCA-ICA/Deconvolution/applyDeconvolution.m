%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets

    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    dataCell = loadBehaviorData(procList{1}{:});
    
    %get traces 
    completeTrace = dataCell{1}.imaging.completeDFFTrace;
    
    %get deconvolved traces 
    
    %add back to dataCell
    dataCell = standaloneCopyDeconvToDataCell(dataCell, deconvTrace);
    dataCell{1}.imaging.completeDeconvTrace = deconvTrace;
    
    %save to processed 
    imTrials = getTrials(dataCell,'maze.crutchTrial==0;imaging.imData==1');
    imTrials = imTrials(~findTurnAroundTrials(imTrials));
    imTrials = binFramesByYPos(imTrials,5);
    saveName = sprintf('%s_%s_processed.mat',procList{dSet}{1},procList{dSet}{2});
    save(fullfile('W:\\Mice',saveName),'dataCell','imTrials');
end 