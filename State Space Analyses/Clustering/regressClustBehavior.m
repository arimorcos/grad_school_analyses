function regressClustBehavior(dataCell,refPoints)
%regressClustBehavior.m Regresses previous clusterIDs and behavioral
%variables against data at a later point
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%
%ASM 4/15

%get clusters 
[neurClusterIDs,behavTracePoints] = getClusters(dataCell);

[clusterCoeff,behavCoeff] = regressAgainstClusters(neurClusterIDs,...
    behavTracePoints,refPoints);

end

function [neurClusterIDs,behavTracePoints] = getClusters(dataCell)
%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%get behavioral traces
behavTraces = catBinnedDataFrames(dataCell);
keepVar = 2:6; %2 - xPos, 3 - yPos, 4 - view angle, 5 - xVel, 6 - yVel
behavTraces = behavTraces(keepVar,:,:);

%get neuronal traces
[~,neuronalTraces] = catBinnedTraces(dataCell);

%get nNeurons
nTrials = size(neuronalTraces,3);

%%%%%%%%% Create matrix of values at each point in the maze

neuronalTracePoints = getMazePoints(neuronalTraces,yPosBins);
behavTracePoints = getMazePoints(behavTraces,yPosBins);
nPoints = size(neuronalTracePoints,2);

%%%%%%%%%%%% cluster
neurClusterIDs = nan(nTrials,nPoints);
for point = 1:nPoints
    neurClusterIDs(:,point) = apClusterNeuronalStates(squeeze(neuronalTracePoints(:,point,:)));
end
end

function [clusterCoeff,behavCoeff] = regressAgainstClusters(neurClusterIDs,...
    behavPoints,refPoints)

%get relevant points 
responseClusterIDs = neurClusterIDs(:,refPoints(2));
explainClusterIDs = neurClusterIDs(:,refPoints(1));
explainBehav = squeeze(behavPoints(:,refPoints(1),:));

%count response clusters 
[uniqueResponse,respCount] = count_unique(responseClusterIDs);

%take two with highest counts 
[~,sortOrder] = sort(respCount,'descend');
compareResponseClusters = uniqueResponse(sortOrder(1:2));

%crop to those trials 
keepInd = ismember(responseClusterIDs,compareResponseClusters);
responseClusterIDs = responseClusterIDs(keepInd);
explainClusterIDs = explainClusterIDs(keepInd);
explainBehav = explainBehav(:,keepInd);

%get unique explainClusterIDs
uniqueExplain = unique(explainClusterIDs);
nExplain = length(uniqueExplain);
nTrials = length(explainClusterIDs);

%convert response cluster to 0 and 1 
responseClusterIDs(responseClusterIDs == compareResponseClusters(1)) = 0;
responseClusterIDs(responseClusterIDs == compareResponseClusters(2)) = 1;

%loop through each explain cluster 
% explainVar = false(nExplain,nTrials);
% for explainInd = 1:nExplain
%     explainVar(explainInd,:) = uniqueExplain(explainInd) == explainClusterIDs;
% end
% 
% %create table 
% clusterTable = array2table(explainVar');

%explain clusters
explainTable = array2table(explainClusterIDs,'VariableNames',{'explainCluster'});

%create behavior table 
behavTable = array2table(explainBehav','VariableNames',{'xPos','yPos','theta','xVel','yVel'});

%create response table 
responseCluster = array2table(responseClusterIDs,'VariableNames',{'responseCluster'});

%concatenate tables 
regressTable = cat(2,explainTable,behavTable,responseCluster);

mdl = fitlm(regressTable,'ResponseVar','responseCluster','CategoricalVars',{'explainCluster'});
keyboard;


end