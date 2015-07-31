%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets

    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    dataCell = loadBehaviorData(procList{dSet}{:});
    
    %add in previous result field
    dataCell = addPrevTrialResult(dataCell);
    
    %get traces 
    completeTrace = dataCell{1}.imaging.completeDFFTrace;
    
    %get deconvolved traces 
    nNeurons = size(completeTrace,1);
    deconvTrace = nan(size(completeTrace));
    parfor neuron = 1:nNeurons
        %deconvolve and smooth (one second)
        deconvTrace(neuron,:) = smooth(getDeconv(completeTrace(neuron,:)),30);
    end
    
    %add back to dataCell
    dataCell = standaloneCopyDeconvToDataCell(dataCell, deconvTrace);
    dataCell{1}.imaging.completeDeconvTrace = deconvTrace;
    
    %filter roiGroups
    dataCell = filterROIGroups(dataCell,1);
    
    %save to processed 
    imTrials = getTrials(dataCell,'maze.crutchTrial==0;imaging.imData==1');
    imTrials = imTrials(~findTurnAroundTrials(imTrials));
    imTrials = binFramesByYPos(imTrials,5);
    saveName = sprintf('%s_%s_processed.mat',procList{dSet}{1},procList{dSet}{2});
    save(fullfile('W:\\Mice',saveName),'dataCell','imTrials');
end 