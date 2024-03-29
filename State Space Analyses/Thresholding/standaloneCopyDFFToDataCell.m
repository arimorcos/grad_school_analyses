function dataCell = standaloneCopyDFFToDataCell(dataCell,dFFTraces,dGRTraces)
%copyDFFToDataCell.m Copies subsetted data array and dFFTraces into
%appropriate trial within dataCell
%
%INPUTS
%dataCell - cell array of data structures
%dFFTraces - 1 x nPlanes cell array containing nCells x nFrames array containing dF/F as percentage
%
%OUTPUTS
%dataCell - cell array of data structures
%
%ASM 10/13

if ~iscell(dFFTraces)
    dFFTraces = {dFFTraces};
    if exist('dGRTraces','var')
        dGRTraces = {dGRTraces};
    end
end

for planeNum = 1:length(dataCell{1}.imaging.nCellsPlane)

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
            dFFTraces{planeNum}(:,frameInd);
        if exist('dGRTraces','var')
            dataCell{uniqueTrials(trialInd)}.imaging.dGRTraces{planeNum} =...
                dGRTraces{planeNum}(:,frameInd);
        end

        %change imData to true
        dataCell{uniqueTrials(trialInd)}.imaging.imData = true;

    end
    
end
