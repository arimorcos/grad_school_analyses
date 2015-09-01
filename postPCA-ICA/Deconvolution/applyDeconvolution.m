%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

% nDataSets = 1;
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
    c = nan(size(completeTrace));
    g = cell(nNeurons,1);
    parfor neuron = 1:nNeurons
        %deconvolve and smooth (1/3 second)
        %         deconvTrace(neuron,:) = smooth(getDeconv(completeTrace(neuron,:)),10);
        try
            [c(neuron,:),~,~,g{neuron},~,deconvTrace(neuron,:)] = constrained_foopsi(completeTrace(neuron,:));
            
            deconvTrace(neuron,:) = deconvTrace(neuron,:)/0.1;
        catch
            deconvTrace(neuron,:) = getDeconv(completeTrace(neuron,:))/0.1;
        end
        %         deconvTrace(neuron,:) = smooth(deconvTrace(neuron,:),10)
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
    save(fullfile('W:\\Mice\\FoopsiTest',saveName),'dataCell','imTrials');
    
    %save g and c 
    save(fullfile('D:\\DATA\\Analyzed Data\\150901_foopsi_info',saveName),'c','g','deconvTrace','completeTrace');
end