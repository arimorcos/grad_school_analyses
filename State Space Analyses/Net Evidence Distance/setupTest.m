mouse = 'AM136'; date = '140820';
% mouse = 'AM131'; date = '140911';
% mouse = 'AM150'; date = '141128';
% mouse = 'AM150'; date = '141206';
% mouse = 'AM144'; date = '141203';

%parameters
trialFilter = [];
shouldRedo = ~true;
elimInactive = ~true;
shouldThresh = false;
shouldZScore = false;
shouldFactor = true;
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
leftTrials = getTrials(imTrials,'maze.leftTrial==1');
rightTrials = getTrials(imTrials,'maze.leftTrial==0');
trials60 = getTrials(imTrials,'maze.numLeft==0,6');
correctTrials = getTrials(imTrials,'result.correct==1');
errorTrials = getTrials(imTrials,'result.correct==0');