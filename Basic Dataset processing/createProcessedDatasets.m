function createProcessedDatasets(mouse,date)

%parameters
trialFilter = [];
shouldRedo = ~true;
elimInactive = ~true;
shouldThresh = false;
shouldZScore = false;
shouldFactor = false;
nSTD = 2.5;
minFrames = 8;
transThresh = 1;
keepGroups = 1;
skipIndFactors = [2 3];

dataCell = loadBehaviorData(mouse,date);

%add in previous result field
dataCell = addPrevTrialResult(dataCell);

%trial filter
if exist('trialFilter','var') && ~isempty(trialFilter)
    dataCell = dataCell(trialFilter);
end

%filter roiGroups
dataCell = filterROIGroups(dataCell,keepGroups);

%get roiGroups
roiGroups = dataCell{find(findTrials(dataCell,'imaging.imData==1'),1)}.imaging.roiGroups{1};

%check if factor analysis is present
if ~isfield(dataCell{1}.imaging,'factorAn') || shouldRedo
    
    if shouldFactor
        %perform factor analysis
        fprintf('Starting factor analysis...');
        dataCell = factorAnalysisDataCell(dataCell,'skipInd',skipIndFactors);
        fprintf('Complete\n');
    end
    
    %get traces
    dFFTraces = dataCell{1}.imaging.completeDFFTrace;
    %     dGRTraces = dataCell{1}.imaging.completeDGRTrace;
    
    %filter
    dFFTraces = dFFTraces(ismember(roiGroups,keepGroups),:);
    
    %     %threshold
    if shouldThresh
        dFFTraces = thresholdCompleteTrace(dFFTraces,nSTD,minFrames);
        %         dGRTraces = thresholdCompleteTrace(dGRTraces,nSTD,minFrames);
    end
    
    %zscore
    if shouldZScore
        dFFTraces = zScoreTraces(dFFTraces);
        %         dGRTraces = zScoreTraces(dGRTraces);
    end
    
    %eliminate cells with fewer than 0.2 transients per minute
    if elimInactive
        if isfield(dataCell{1}.sImage,'scanFrameRate')
            frameRate = dataCell{1}.sImage.scanFrameRate;
        elseif isfield(dataCell{1}.sImage,'scanFramePeriod');
            frameRate = 1/dataCell{1}.sImage.scanFramePeriod;
        end
        nTransPerMinDFF = getNTransPerMin(dFFTraces,frameRate);
        for i = 1:length(nTransPerMinDFF)
            dFFTraces(nTransPerMinDFF{i} < transThresh,:) = [];
            %             dGRTraces(nTransPerMinDFF{i} < transThresh,:) = [];
        end
    end
    
    %copy back
    dataCell = standaloneCopyDFFToDataCell(dataCell,dFFTraces);
    
    %save
    save(getBehaviorPath(mouse,date),'dataCell');
end


imTrials = getTrials(dataCell,'maze.crutchTrial==0;imaging.imData==1');
imTrials = imTrials(~findTurnAroundTrials(imTrials));
%bin traces
imTrials = binFramesByYPos(imTrials,5);
savePath = sprintf('D:\\DATA\\Analyzed Data\\Mice\\%s_%s_processed.mat',mouse,date);
save(savePath,'imTrials','dataCell');