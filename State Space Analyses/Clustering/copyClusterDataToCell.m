function dataCell = copyClusterDataToCell(dataCell,data,dsamp)
%copyClusterDataToCell.m Copies clustered dataFrames to imaging cell 
%
%INPUTS
%dataCell 
%dsamp - downsample factor used in clustering
%
%OUTPUTS
%dataCell - dataCell with clustered data
%
%ASM 4/15

%get completeTrace
completeTrace = dataCell{1}.imaging.completeDFFTrace;
trialIDs = dataCell{1}.imaging.trialIDs;

%get frame indices 
frameInd = 1:dsamp:size(completeTrace,2);
frameInd = bsxfun(@plus,frameInd',0:dsamp-1);
newNFrames = size(frameInd,1);

%take average of trialIDs
newTrialIDs = nan(2,newNFrames);
for currFrame = 1:newNFrames
    newTrialIDs(:,currFrame) = max(trialIDs(:,frameInd(currFrame,:)),[],2);
end

%get binned dataFrames 
clusterDataFrames

keyboard;
