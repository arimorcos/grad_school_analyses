function mMat = createTransitionMatrix(clusterIDs)
%createTransitionMatrix.m Given a set of cluster ids and unique clusters,
%creates a transition matrix 
%
%INPUTS
%clusterIDs - nTrials x nPoints array of cluster ids 
%
%OUTPUTS
%mMat - nPoints-1 x 1 cell array of nClustersPointN x
%   nClustersPointN+1 matrix of transition probabilities
%
%ASM 4/15

%% get relevant variables 
[nTrials, nPoints] = size(clusterIDs);

%get number of unique
uniqueClusters = arrayfun(@(x) unique(clusterIDs(:,x)),1:nPoints,'UniformOutput',false);
nUnique = cellfun(@length,uniqueClusters);


%% get transitions
transMat = cell(nPoints-1,1);
for point = 1:(nPoints-1)
    
    %initialize transMat
    transMat{point} = zeros(nUnique(point),nUnique(point+1));
    
    % loop through each trial
    for trialInd = 1:nTrials
        currID = find(clusterIDs(trialInd,point) == uniqueClusters{point});
        newID = find(clusterIDs(trialInd,point+1) == uniqueClusters{point+1});
        transMat{point}(currID,newID) = transMat{point}(currID,newID) + 1;
    end
end

%normalize to get mMat
mMat = cellfun(@(x) x./nTrials,transMat,'UniformOutput',false);