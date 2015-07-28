function out = indNeuronClusterRegression(dataCell)
%indNeuronClusterRegression.m In a leave-one-out fashion, performs
%clustering (one clustering pattern) using all cells but the excluded
%(test) neuron, then peerforms multivariate stepwise regression to try to
%explain the test neuron's activity based on which cluster the current
%trial is in and the upcoming turn. Coefficient for the cluster would
%suggest within highway explanatory power, while coefficient for the turn
%would suggest across highway explanatory power. The ratio of these
%coefficients could be highly informative.
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%
%ASM 7/15


% if nargin < 2 || isempty(shouldShuffle)
%     shouldShuffle = false;
% end

%filter to correct 6-0 trials
trials60 = getTrials(dataCell,'maze.numLeft==0,6;result.correct==1');

%get turn direction
leftTurn = getCellVals(trials60,'result.leftTurn')';
turn = reshape(repmat(leftTurn,1,10),[],1);

%get yPosBins
yPosBins = trials60{1}.imaging.yPosBins;

%get traces
[~,traces] = catBinnedTraces(trials60);

%shuffle
% if shouldShuffle
%     tempTraces = reshape(traces,size(traces,1),[]);
%     nValues = size(tempTraces,2);
%     for neuron = 1:size(tempTraces,1)
%         tempTraces(neuron,:) = circshift(tempTraces(neuron,:),[0 randi(nValues)]);
%     end
%     traces = reshape(tempTraces,size(traces));
% end

%get nNeurons
nNeurons = size(traces,1);

%%%%%%%%% Create matrix of values at each point in the maze

tracePoints = getMazePoints(traces,yPosBins);

%% loop through and cluster indpendently for each
perc = 10;
nShuffles = 1000;

%initialize
% meanClusterValue = nan(nNeurons,1);
% clusterValue = nan(nNeurons,1);
% turnValue = nan(nNeurons,1);
% rsquared = nan(nNeurons,1);
totalR2 = nan(nNeurons,1);
clusterR2 = nan(nNeurons,1);
turnR2 = nan(nNeurons,1);

shuffleClusterTotalR2 = nan(nNeurons,nShuffles);
shuffleClusterClusterR2 = nan(nNeurons,nShuffles);
shuffleClusterTurnR2 = nan(nNeurons,nShuffles);

shuffleTurnTotalR2 = nan(nNeurons,nShuffles);
shuffleTurnClusterR2 = nan(nNeurons,nShuffles);
shuffleTurnTurnR2 = nan(nNeurons,nShuffles);

shuffleBothTotalR2 = nan(nNeurons,nShuffles);
shuffleBothClusterR2 = nan(nNeurons,nShuffles);
shuffleBothTurnR2 = nan(nNeurons,nShuffles);

clusterMeanAct = cell(nNeurons,1);
clusterPLeft = cell(nNeurons,1);
clusterNPoints = cell(nNeurons,1);
clusterTurnAct = cell(nNeurons,1);
clusterNPointsTurn = cell(nNeurons,1);
clusterNPointsTurnClustering = cell(nNeurons,1);
clusterPLeftTurn = cell(nNeurons,1);
clusterMeanTurn = cell(nNeurons,1);

%loop
parfor neuronInd = 1:nNeurons
    
    %filter tracePoints
    tempTracePoints = tracePoints(setdiff(1:nNeurons,neuronInd),:,:);
    
    % cluster
    reshapePoints = reshape(tempTracePoints,size(tempTracePoints,1),...
        size(tempTracePoints,2)*size(tempTracePoints,3));
    allClusterIDs = apClusterNeuronalStates(reshapePoints, perc);
    clusterIDs = reshape(allClusterIDs,size(tempTracePoints,3),size(tempTracePoints,2));
    turnClusterIDs = apClusterNeuronalStates(squeeze(tempTracePoints(:,10,:)),perc);
    
    %get testTrace
    testTrace = squeeze(tracePoints(neuronInd,:,:))';
    
    %     %create table
    %     regTable = table(testTrace(:),clusterIDs(:),reshape(repmat(leftTurn,1,10),[],1),...
    %         'VariableNames',{'nActivity','clusterIDs','turn'});
    %
    %     %perform regression
    %     mdl = stepwiselm(regTable,'linear','CategoricalVars',{'clusterIDs','turn'},...
    %         'ResponseVar','nActivity');
    %
    %     %get significant coefficients
    %     keepCoeff = mdl.Coefficients;
    % %     keepCoeff = mdl.Coefficients(mdl.Coefficients.pValue < 0.05,:);
    %
    %     %remove interactions
    %     hasNoColon = cellfun(@isempty,strfind(keepCoeff.Properties.RowNames,':'));
    %     keepCoeff = keepCoeff(hasNoColon,:);
    %
    %     %find turn values
    %     isTurnCoeff = ~cellfun(@isempty, strfind(keepCoeff.Properties.RowNames,'turn'));
    % %     if any(isTurnCoeff)
    %         turnValue(neuronInd) = sum(abs(keepCoeff.Estimate(isTurnCoeff)));
    % %     else
    % %         turnValue(neuronInd) = 0;
    % %     end
    %
    %     %find cluster values
    %     isClusterCoeff = ~cellfun(@isempty, strfind(keepCoeff.Properties.RowNames,'cluster'));
    % %     if any(isClusterCoeff)
    %         clusterValue(neuronInd) = sum(abs(keepCoeff.Estimate(isClusterCoeff)));
    %         meanClusterValue(neuronInd) = clusterValue(neuronInd)/sum(isClusterCoeff);
    % %     else
    % %         clusterValue(neuronInd) = 0;
    % %     end
    %
    %     %get model fit
    %     rsquared(neuronInd) = mdl.Rsquared.Adjusted;
    
    
    %get mean value for each cluster 
    uniqueClusters = unique(clusterIDs(:));
    nUniqueClusters = length(uniqueClusters);
    clusterMeanAct{neuronInd} = nan(nUniqueClusters,1);
    clusterPLeft{neuronInd} = nan(nUniqueClusters,1);
    testTurn = reshape(turn,size(testTrace));
    clusterTurnAct{neuronInd} = nan(nUniqueClusters,1);
    clusterNPointsTurn{neuronInd} = nan(nUniqueClusters,1);
    for cluster = 1:nUniqueClusters
        clusterMeanAct{neuronInd}(cluster) = ...
            mean(testTrace(clusterIDs == uniqueClusters(cluster)));
        clusterPLeft{neuronInd}(cluster) = ...
            mean(testTurn(clusterIDs == uniqueClusters(cluster)));
        clusterNPoints{neuronInd}(cluster) = ...
            sum(sum(clusterIDs == uniqueClusters(cluster)));
        clusterTurnAct{neuronInd}(cluster) = ...
            mean(testTrace(clusterIDs(:,10) == uniqueClusters(cluster),10));
        clusterNPointsTurn{neuronInd}(cluster) = ...
            sum(clusterIDs(:,10) == uniqueClusters(cluster));
    end
    
    %get mean value for each turn cluster 
    uniqueTurnClusters = unique(turnClusterIDs);
    nUniqueTurnClusters = length(uniqueTurnClusters);
    clusterMeanTurn{neuronInd} = nan(nUniqueTurnClusters,1);
    clusterPLeftTurn{neuronInd} = nan(nUniqueTurnClusters,1);
    clusterNPointsTurnClustering{neuronInd} = nan(nUniqueTurnClusters,1);
    for cluster = 1:nUniqueTurnClusters
        clusterMeanTurn{neuronInd}(cluster) = mean(tracePoints(neuronInd,10,...
            turnClusterIDs == uniqueTurnClusters(cluster)));
        clusterPLeftTurn{neuronInd}(cluster) = mean(turn(turnClusterIDs == ...
            uniqueTurnClusters(cluster)));
        clusterNPointsTurnClustering{neuronInd}(cluster) = ...
            sum(turnClusterIDs == uniqueTurnClusters(cluster));
    end
    
    %perform ridge 
    [totalR2(neuronInd), turnR2(neuronInd), clusterR2(neuronInd)] =...
        getR2Ridge(clusterIDs,turn,testTrace);
    
    %shuffle and recalculate
    for shuffleInd = 1:nShuffles
        
        %shuffle clusterIDs 
        shuffleIDs = nan(size(clusterIDs));
        for i = 1:size(clusterIDs,2)
            shuffleIDs(:,i) = shuffleArray(clusterIDs(:,i));
        end
        
        %shuffle turn 
        shuffleTurn = nan(size(turn));
        for i = 1:size(turn,2)
            shuffleTurn(:,i) = shuffleArray(turn(:,i));
        end
        
        [shuffleClusterTotalR2(neuronInd,shuffleInd), shuffleClusterTurnR2(neuronInd,shuffleInd),...
            shuffleClusterClusterR2(neuronInd,shuffleInd)] =...
            getR2Ridge(shuffleIDs,turn,testTrace);
        
        [shuffleTurnTotalR2(neuronInd,shuffleInd), shuffleTurnTurnR2(neuronInd,shuffleInd),...
            shuffleTurnClusterR2(neuronInd,shuffleInd)] =...
            getR2Ridge(clusterIDs,shuffleTurn,testTrace);
        
        [shuffleBothTotalR2(neuronInd,shuffleInd), shuffleBothTurnR2(neuronInd,shuffleInd),...
            shuffleBothClusterR2(neuronInd,shuffleInd)] =...
            getR2Ridge(shuffleIDs,shuffleTurn,testTrace);
    end
    
    %display progress
    dispProgress('neuron %d/%d',neuronInd,neuronInd,nNeurons);
end

% out.meanClusterValue = meanClusterValue;
% out.turnValue = turnValue;
% out.clusterValue = clusterValue;
% out.ratio = meanClusterValue./turnValue;
% out.Rsquared = rsquared;

out.clusterR2 = clusterR2;
out.turnR2 = turnR2;
out.totalR2 = totalR2;
out.R2Ratio = clusterR2./turnR2;

out.shuffleCluster.totalR2 = shuffleClusterTotalR2;
out.shuffleCluster.turnR2 = shuffleClusterTurnR2;
out.shuffleCluster.clusterR2 = shuffleClusterClusterR2;
out.shuffleCluster.R2Ratio = shuffleClusterClusterR2./shuffleClusterTurnR2;

out.shuffleTurn.totalR2 = shuffleTurnTotalR2;
out.shuffleTurn.turnR2 = shuffleTurnTurnR2;
out.shuffleTurn.clusterR2 = shuffleTurnClusterR2;
out.shuffleTurn.R2Ratio = shuffleTurnClusterR2./shuffleTurnTurnR2;

out.shuffleBoth.totalR2 = shuffleBothTotalR2;
out.shuffleBoth.turnR2 = shuffleBothTurnR2;
out.shuffleBoth.clusterR2 = shuffleBothClusterR2;
out.shuffleBoth.R2Ratio = shuffleBothClusterR2./shuffleBothTurnR2;

out.clusterMeanActivity = clusterMeanAct;
out.clusterPLeft = clusterPLeft;
out.clusterNPoints = clusterNPoints;
out.clusterNPointsTurn = clusterNPointsTurn;
out.clusterTurnAct = clusterTurnAct;
out.clusterMeanTurn = clusterMeanTurn;
out.clusterPLeftTurn = clusterPLeftTurn;
out.clusterNPointsTurnClustering = clusterNPointsTurnClustering;


end

function [totalR2, turnR2, clusterR2] = getR2Ridge(clusterIDs,turn,testTrace)
%ridge regression
D = x2fx(cat(2,clusterIDs(:),turn),'linear',[1 2]); %create matrix
D(:,1) = []; %remove constant term
b = ridge(testTrace(:),D,0.001); %run with k of 0.001

%calculate totalR2
tempTotalR2 = corrcoef(D*b,testTrace(:));
totalR2 = tempTotalR2(1,2)^2;

%calcualte turn R2
turnB = b;
turnB(1:end-1) = 0;
tempTurnR2 = corrcoef(D*turnB,testTrace(:));
turnR2 = tempTurnR2(1,2)^2;

%calculate cluster R2
clusterB = b;
clusterB(end) = 0;
tempClusterR2 = corrcoef(D*clusterB,testTrace(:));
clusterR2 = tempClusterR2(1,2)^2;
end