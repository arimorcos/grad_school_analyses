function dataCell = softThreshDataCell(dataCell)

dFFTraces = dataCell{1}.imaging.completeDFFTrace;
dGRTraces = dataCell{1}.imaging.completeDGRTrace;

%thresh
dFFThresh = dFFTraces;
dGRThresh = dGRTraces;
dFFThresh(dFFThresh < -10) = -10;
dGRThresh(dGRThresh < -10) = -10;
dFFThresh(~isfinite(dFFThresh)) = -10;
dGRThresh(~isfinite(dGRThresh)) = -10;
dFFThresh = {dFFThresh};
dGRThresh = {dGRThresh};

%copy back
planeNum = 1;
%get number of unique, complete trials
uniqueTrials = unique(dataCell{1}.imaging.trialIDs(2*planeNum-1,...
    logical(dataCell{1}.imaging.trialIDs(2*planeNum,:))));
nUniqueTrials = length(uniqueTrials);

%cycle through each unique trial
for trialInd = 1:nUniqueTrials
    
    %get frameInd corresponding to trial
    frameInd = dataCell{1}.imaging.trialIDs(2*planeNum-1,:) == uniqueTrials(trialInd);
    
    %store dFFTraces subset in dataCell
    dataCell{uniqueTrials(trialInd)}.imaging.dFFTraces{planeNum} =...
        dFFThresh{planeNum}(:,frameInd);
    dataCell{uniqueTrials(trialInd)}.imaging.dGRTraces{planeNum} =...
        dGRThresh{planeNum}(:,frameInd);
    
    %change imData to true
    dataCell{uniqueTrials(trialInd)}.imaging.imData = true;
    
end