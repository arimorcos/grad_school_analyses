function dataCell = copyClusterDataToCell(dataCell,dsamp)
%copyClusterDataToCell.m Copies clustered dataFrames to imaging cell 
%
%INPUTS
%dataCell - dataCell containing completeDataFrames
%dsamp - downsample factor used in clustering
%
%OUTPUTS
%dataCell - dataCell with clustered data
%
%ASM 4/15

%get completeTrace
completeTrace = dataCell{1}.imaging.completeDFFTrace;
completeDataFrames = dataCell{1}.imaging.completeDataFrames;
trialIDs = dataCell{1}.imaging.trialIDs;
nTrials = length(dataCell);

%get frame indices 
frameInd = 1:dsamp:size(completeTrace,2);
frameInd = bsxfun(@plus,frameInd',0:dsamp-1);
newNFrames = size(frameInd,1);

%take max value of trialIDs and average of complete dataframes
newTrialIDs = nan(2,newNFrames);
clusterDataFrames = nan(size(completeDataFrames,1),newNFrames);
for currFrame = 1:newNFrames
    newTrialIDs(:,currFrame) = max(trialIDs(:,frameInd(currFrame,:)),[],2);
    clusterDataFrames(:,currFrame) = mean(completeDataFrames(:,frameInd(currFrame,:)),2);
end

%store
dataCell{1}.imaging.clusterTrialIDs = newTrialIDs;
dataCell{1}.imaging.clusterDataFrames = clusterDataFrames;
