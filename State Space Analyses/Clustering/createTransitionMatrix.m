function mMat = createTransitionMatrix(clusterIDs,limit,clusterSub)
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

if nargin < 3 || isempty(clusterSub)
    clusterSub = [];
end
if nargin < 2 
    limit = [];
end

%% get relevant variables 
[nTrials, nPoints] = size(clusterIDs);

%get number of unique
uniqueClusters = arrayfun(@(x) unique(clusterIDs(:,x)),1:nPoints,'UniformOutput',false);
nUnique = cellfun(@length,uniqueClusters);

%% limit
if ~isempty(limit)
    keepInd = clusterIDs(:,1) == limit;
    clusterIDs = clusterIDs(keepInd,:);
    nTrials = sum(keepInd);
end

%% cluster sub 
if ~isempty(clusterSub)
    nTrials = size(clusterSub,1);
else
    clusterSub = clusterIDs;
end

%% get transitions
transMat = cell(nPoints-1,1);
for point = 1:(nPoints-1)
    
    %initialize transMat
    transMat{point} = zeros(nUnique(point),nUnique(point+1));
    
    % loop through each trial
    for trialInd = 1:nTrials
        currID = find(clusterSub(trialInd,point) == uniqueClusters{point});
        newID = find(clusterSub(trialInd,point+1) == uniqueClusters{point+1});
        transMat{point}(currID,newID) = transMat{point}(currID,newID) + 1;
    end
end

%normalize to get mMat
mMat = cellfun(@(x) x./nTrials,transMat,'UniformOutput',false);