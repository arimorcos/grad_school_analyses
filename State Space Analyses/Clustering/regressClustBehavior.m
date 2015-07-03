function out = regressClustBehavior(dataCell)
%regressClustBehavior.m Regresses previous clusterIDs and behavioral
%variables against data at a later point
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%out - structure containing matrices of the following
%   adjR2Behav - adjusted R^2 for only the behavioral regression
%   adjR2BehavNeur - adjusted R^2 for regression with both behavior and
%       clusters
%   RMSEBehav - RMSE for only the behavioral regression
%   RMSEBehavNeur - RMSE for regression with both behavior and clusters
%
%ASM 7/15

%get clusters
[neurClusterIDs,behavTracePoints] = getClusters(dataCell);

%get real performance
[adjR2Behav, adjR2BehavNeur, RMSEBehav, RMSEBehavNeur] = ...
    calculateModelPerf(neurClusterIDs, behavTracePoints, false);

% get shuffled performance
nShuffles = 100;
nPoints = size(neurClusterIDs,2);
adjR2BehavShuffle = nan(nPoints,nPoints,nShuffles);
adjR2BehavNeurShuffle = nan(size(adjR2BehavShuffle));
RMSEBehavShuffle = nan(size(adjR2BehavShuffle));
RMSEBehavNeurShuffle = nan(size(adjR2BehavShuffle));
parfor shuffleInd = 1:nShuffles
    
    %shuffle clusterIDs
    shuffleClusterIDs = nan(size(neurClusterIDs));
    for point = 1:nPoints
        shuffleClusterIDs(:,point) = shuffleArray(neurClusterIDs(:,point));
    end
    
    % get model performance
    [adjR2BehavShuffle(:,:,shuffleInd), adjR2BehavNeurShuffle(:,:,shuffleInd),...
        RMSEBehavShuffle(:,:,shuffleInd), RMSEBehavNeurShuffle(:,:,shuffleInd)] = ...
        calculateModelPerf(shuffleClusterIDs, behavTracePoints, true);
    
    %display progress
    %     dispProgress('Shuffling model %d/%d',shuffleInd, shuffleInd, nShuffles);
end

%% take averages across diagonals

%get distance matrix
pointDist = triu(squareform(pdist((1:nPoints)')));

%initialize regular
adjR2BehavDelta = nan(nPoints,1);
adjR2BehavNeurDelta = nan(size(adjR2BehavDelta));
RMSEBehavDelta = nan(size(adjR2BehavDelta));
RMSEBehavNeurDelta = nan(size(adjR2BehavDelta));

%initialize shuffles
adjR2BehavNeurDeltaShuffle = nan(nPoints,nShuffles);
RMSEBehavNeurDeltaShuffle = nan(size(adjR2BehavNeurDeltaShuffle));

%loop through each transition
for delta = 0:(nPoints-1)
    
    %get matchInd
    if delta > 0
        matchInd = pointDist == delta;
    else
        matchInd = sub2ind([nPoints nPoints],1:nPoints,1:nPoints);
    end
    
    % take mean of matching indices for regulars
    adjR2BehavDelta(delta+1) = nanmean(adjR2Behav(matchInd));
    adjR2BehavNeurDelta(delta+1) = nanmean(adjR2BehavNeur(matchInd));
    RMSEBehavDelta(delta+1) = nanmean(RMSEBehav(matchInd));
    RMSEBehavNeurDelta(delta+1) = nanmean(RMSEBehavNeur(matchInd));
    
    % take mean of matching indices for shuffles
    for shuffleInd = 1:nShuffles
        
        %         tempAdjR2BehavShuffle = in.adjR2BehavShuffle(:,:,shuffleInd);
        %         adjR2BehavDeltaShuffle(delta+1,shuffleInd) = nanmean(tempAdjR2BehavShuffle(matchInd));
        
        tempAdjR2BehavNeurShuffle = adjR2BehavNeurShuffle(:,:,shuffleInd);
        adjR2BehavNeurDeltaShuffle(delta+1,shuffleInd) = nanmean(tempAdjR2BehavNeurShuffle(matchInd));
        
        %         tempRMSEBehavShuffle = in.RMSEBehavShuffle(:,:,shuffleInd);
        %         RMSEBehavDeltaShuffle(delta+1,shuffleInd) = nanmean(tempRMSEBehavShuffle(matchInd));
        
        tempRMSEBehavNeurShuffle = RMSEBehavNeurShuffle(:,:,shuffleInd);
        RMSEBehavNeurDeltaShuffle(delta+1,shuffleInd) = nanmean(tempRMSEBehavNeurShuffle(matchInd));
    end
    
end


%store output
out.adjR2Behav = adjR2Behav;
out.RMSEBehav = RMSEBehav;
out.adjR2BehavNeur = adjR2BehavNeur;
out.RMSEBehavNeur = RMSEBehavNeur;
out.adjR2BehavShuffle = adjR2BehavShuffle;
out.adjR2BehavNeurShuffle = adjR2BehavNeurShuffle;
out.RMSEBehavShuffle = RMSEBehavShuffle;
out.RMSEBehavNeurShuffle = RMSEBehavNeurShuffle;
out.RMSEBehavNeurDeltaShuffle = RMSEBehavNeurDeltaShuffle;
out.adjR2BehavNeurDeltaShuffle = adjR2BehavNeurDeltaShuffle;
out.RMSEBehavNeurDelta = RMSEBehavNeurDelta;
out.RMSEBehavDelta = RMSEBehavDelta;
out.adjR2BehavNeurDelta = adjR2BehavNeurDelta;
out.adjR2BehavDelta = adjR2BehavDelta;
end

function [adjR2Behav, adjR2BehavNeur, RMSEBehav, RMSEBehavNeur] = ...
    calculateModelPerf(neurClusterIDs, behavTracePoints, isShuffle)

%get num points
nPoints = size(neurClusterIDs,2);

%initialize
adjR2Behav = nan(nPoints);
adjR2BehavNeur = nan(nPoints);
RMSEBehav = nan(nPoints);
RMSEBehavNeur = nan(nPoints);

%loop through combination of points
% ind = 1;
% nComb = nPoints^2/2 + (nPoints/2) + 1;
for point1 = 1:nPoints
    for point2 = point1:nPoints
        
        %display progress
        %         dispProgress('Calculating models %d/%d',ind, ind, nComb);
        try
            %calculate models
            [behavModel,behavAndClustModel] = regressAgainstClusters(neurClusterIDs,...
                behavTracePoints,[point1, point2], isShuffle);
            
            %store adjR2 and RMSE
            if ~isShuffle
                adjR2Behav(point1,point2) = behavModel.Rsquared.Adjusted;
                RMSEBehav(point1,point2) = behavModel.RMSE;
            end
            if point1 ~= point2
                adjR2BehavNeur(point1,point2) = behavAndClustModel.Rsquared.Adjusted;
                RMSEBehavNeur(point1,point2) = behavAndClustModel.RMSE;
            end
        end
        %increment ind
        %         ind = ind+1;
    end
end

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

function [behavModel,behavAndClustModel] = regressAgainstClusters(neurClusterIDs,...
    behavPoints,refPoints,isShuffle)

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
behavAndClustRegressTable = cat(2,explainTable,behavTable,responseCluster);
behavRegressTable = cat(2,behavTable,responseCluster);


if refPoints(1) ~= refPoints(2)
    behavAndClustModel = fitlm(behavAndClustRegressTable,'ResponseVar','responseCluster','CategoricalVars',{'explainCluster'});
    %     behavAndClustModel = stepwiselm(behavAndClustRegressTable,...
    %         'ResponseVar','responseCluster','CategoricalVars',{'explainCluster'},...
    %         'Verbose',0);
else
    behavAndClustModel = [];
end
if ~isShuffle
    behavModel = fitlm(behavRegressTable,'ResponseVar','responseCluster');
else
    behavModel = [];
end
% behavModel = stepwiselm(behavRegressTable,'ResponseVar','responseCluster','Verbose',0);
end