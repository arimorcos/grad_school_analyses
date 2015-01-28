function dataCell = copyDFFToDataCell(dataCell,dataFrames,dFFTraces,PCA,...
    variance,trialIDs,whichPlane)
%copyDFFToDataCell.m Copies subsetted data array and dFFTraces into
%appropriate trial within dataCell
%
%INPUTS
%dataCell - cell array of data structures
%dataFrames - nSavedVals x nFrames array containing the averaged values of
%   each saved val for each frame (output of subDataByFrames.m)
%dFFTraces - nCells x nFrames array containing dF/F as percentage
%PCA - nPCs x nFrames array of principal component scores
%variance - nPCs x 1 array of total variance accounted for
%trialIDs - 2 x nFrames array containing the corresponding trial number of
%       each frame (row 1) and a 0 or 1 indicating whether complete trial
%       is present (row 2) (output of subDataByFrames.m)
%whichPlane - plane number for cell
%
%OUTPUTS
%dataCell - cell array of data structures
%
%ASM 10/13

%store complete dFFTrace in 1st trial
if isfield(dataCell{1}.imaging,'completeDFFTrace')
    dataCell{1}.imaging.completeDFFTrace = cat(1,dataCell{1}.imaging.completeDFFTrace,dFFTraces);
else
    dataCell{1}.imaging.completeDFFTrace = dFFTraces;
end

if isfield(dataCell{1}.imaging,'completeDFFTracePlanes')
    dataCell{1}.imaging.completeDFFTracePlanes{length(dataCell{1}.imaging.completeDFFTracePlanes)+1}...
        = dFFTraces;
else
    dataCell{1}.imaging.completeDFFTracePlanes{1} = dFFTraces;
end

if isfield(dataCell{1}.imaging,'nCellsPlane')
    dataCell{1}.imaging.nCellsPlane(length(dataCell{1}.imaging.nCellsPlane)+1)...
        = size(dFFTraces,1);
else
    dataCell{1}.imaging.nCellsPlane = size(dFFTraces,1);
end

if isfield(dataCell{1}.imaging,'trialIDs')
    dataCell{1}.imaging.trialIDs = cat(1,dataCell{1}.imaging.trialIDs,trialIDs);
else
    dataCell{1}.imaging.trialIDs = trialIDs;
end

%get number of unique, complete trials
uniqueTrials = unique(trialIDs(1,logical(trialIDs(2,:))));
nUniqueTrials = length(uniqueTrials);

%cycle through each unique trial
for i = 1:nUniqueTrials
    
    %get frameInd corresponding to trial
    frameInd = trialIDs(1,:) == uniqueTrials(i);
    
    %store dataFrames subset in dataCell
    dataCell{uniqueTrials(i)}.imaging.dataFrames{whichPlane} = dataFrames(:,frameInd);
    
    %store dFFTraces subset in dataCell
    dataCell{uniqueTrials(i)}.imaging.dFFTraces{whichPlane} = dFFTraces(:,frameInd);
    
    %store PCA subset
    dataCell{uniqueTrials(i)}.imaging.PCATraces{whichPlane} = PCA(:,frameInd);
    
    %store variance
    dataCell{uniqueTrials(i)}.imaging.varAccounted = variance;
    
    %change imData to true
    dataCell{uniqueTrials(i)}.imaging.imData = true;
    
end
