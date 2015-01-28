function dataCell = copyFDataToCell(dataCell,trialIDs,whichPlane,dataFrames,...
    dFFTraces,roiGroups,dGRTraces,meanG,meanR,dFFPCA,dFFVar,dGRPCA,dGRVar)
%copyDFFToDataCell.m Copies subsetted data array and dFFTraces into
%appropriate trial within dataCell
%
%INPUTS
%dataCell - cell array of data structures
%dataFrames - nSavedVals x nFrames array containing the averaged values of
%   each saved val for each frame (output of subDataByFrames.m)
%dFFTraces - nCells x nFrames array containing dF/F as percentage
%roiGroups - labels of each roi
%dGRTraces - nCells x nFrames array containing dG/R as percentage
%meanF - nCells x nFrames array of unmodified green fluorescence
%meanR - nCells x nFrames array of unmodified red fluorescence
%dFFPCA - nPCs x nFrames array of principal component scores for dF/F
%dFFVar - nPCs x 1 array of total variance accounted for for dF/F
%dGRPCA - nPCs x nFrames array of principal component scores for dG/R
%dGRVar - nPCs x 1 array of total variance accounted for for dG/R
%trialIDs - 2 x nFrames array containing the corresponding trial number of
%       each frame (row 1) and a 0 or 1 indicating whether complete trial
%       is present (row 2) (output of subDataByFrames.m)
%whichPlane - plane number for cell
%
%OUTPUTS
%dataCell - cell array of data structures
%
%ASM 10/13
if ~exist('roiGroups','var') || isempty(roiGroups)
    roiGroups = ones(size(dFF,1),1);
end

%store complete dFFTrace in 1st trial
if isfield(dataCell{1}.imaging,'completeDFFTrace')
    dataCell{1}.imaging.completeDFFTrace = cat(1,dataCell{1}.imaging.completeDFFTrace,dFFTraces);
else
    dataCell{1}.imaging.completeDFFTrace = dFFTraces;
end

if exist('dGRTraces','var')
    if isfield(dataCell{1}.imaging,'completeDGRTrace')
        dataCell{1}.imaging.completeDGRTrace = cat(1,dataCell{1}.imaging.completeDGRTrace,dGRTraces);
    else
        dataCell{1}.imaging.completeDGRTrace = dGRTraces;
    end
end

if exist('meanG','var')
    if isfield(dataCell{1}.imaging,'completeMeanGTrace')
        dataCell{1}.imaging.completeMeanGTrace = cat(1,dataCell{1}.imaging.completeMeanGTrace,meanG);
    else
        dataCell{1}.imaging.completeMeanGTrace = meanG;
    end
end

if exist('meanR','var')
    if isfield(dataCell{1}.imaging,'completeMeanRTrace')
        dataCell{1}.imaging.completeMeanRTrace = cat(1,dataCell{1}.imaging.completeMeanRTrace,meanR);
    else
        dataCell{1}.imaging.completeMeanRTrace = meanR;
    end
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
    
    %store roiGroups
    dataCell{uniqueTrials(i)}.imaging.roiGroups{whichPlane} = roiGroups;
    
    if exist('dGRTraces','var')
        dataCell{uniqueTrials(i)}.imaging.dGRTraces{whichPlane} = dGRTraces(:,frameInd);
    end
    
    %store PCA subset
    if exist('dFFPCA','var')
        dataCell{uniqueTrials(i)}.imaging.dFFPCA{whichPlane} = dFFPCA(:,frameInd);
    end
    
    if exist('dGRPCA','var')
        dataCell{uniqueTrials(i)}.imaging.dGRPCA{whichPlane} = dGRPCA(:,frameInd);
    end
    
    %store variance
    if exist('dFFVar','var')
        dataCell{uniqueTrials(i)}.imaging.dFFVarAccounted = dFFVar;
    end
    
    if exist('dGRVar','var')
        dataCell{uniqueTrials(i)}.imaging.dGRVarAccounted = dGRVar;
    end
    
    %change imData to true
    dataCell{uniqueTrials(i)}.imaging.imData = true;
    
end
