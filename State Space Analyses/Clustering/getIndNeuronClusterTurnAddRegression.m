function out = getIndNeuronClusterTurnAddRegression(dataCell)
%getIndNeuronClusterTurnAddRegression.m Performs regression using just the
%cluster IDs, just the turn identity, or both to try to predict a given
%neuron's activity
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%out - stucture containing:
%
%
%ASM 10/15

traceType = 'deconv';
whichEpoch = 10;
nShuffles = 100;
clusterIndForEachNeuron = true;
perc = 10;
useGLM = false;

if ~clusterIndForEachNeuron
    %cluster
    [~,~,clusterIDs,~] = getClusteredMarkovMatrix(dataCell, 'traceType', traceType);
    %get which cluster
    clusterIDs = clusterIDs(:, whichEpoch);
end

%get traces
switch lower(traceType)
    case 'deconv'
        traces = catBinnedDeconvTraces(dataCell);
    case 'dff'
        [~,traces] = catBinnedTraces(dataCell);
    otherwise
        error('Can''t interpret traceType: %s', traceType);
end

%get tracePoints
tracePoints = getMazePoints(traces, dataCell{1}.imaging.yPosBins);

%crop
tracePoints = squeeze(tracePoints(:, whichEpoch, :));

%get nNeurons
nNeurons = size(tracePoints, 1);

%get turn
leftTurn = getCellVals(dataCell, 'result.leftTurn');

%initialize
% clusterR2 = nan(nNeurons,1);
turnR2 = nan(nNeurons,1);
bothR2 = nan(nNeurons,1);
shuffleR2 = nan(nNeurons, nShuffles);

warning('off','stats:LinearModel:RankDefDesignMat');

% loop thorugh each neuron
for neuron = 1:nNeurons
    
    %get neuron points
    neuronPoints = tracePoints(neuron,:)';
    
    if clusterIndForEachNeuron
        clusterIDs = apClusterNeuronalStates(...
            tracePoints(setdiff(1:nNeurons,neuron),:), perc);
    end
    
    % perform regression for just cluster ids
    %     clusterModel = fitlm(cat(2, ones(size(clusterIDs)), clusterIDs),...
    %         neuronPoints, 'CategoricalVars',2);
    
    % perform regression for just turn
    if ~useGLM
        turnModel = fitlm(leftTurn, neuronPoints, 'CategoricalVars', 1);
    else
        turnModel = fitlm(leftTurn, neuronPoints, 'CategoricalVars', 1,...
            'link', 'logit', 'Distribution', 'Poisson');
    end
    
    %perform regression for both
    if ~useGLM
        bothModel = fitlm(cat(2,clusterIDs, leftTurn'), neuronPoints, ...
            'CategoricalVars',[1 2]);
    else
        bothModel = fitlm(cat(2,clusterIDs, leftTurn'), neuronPoints, ...
            'CategoricalVars',[1 2], 'Distribution', 'Poisson', 'link', 'logit');
    end
    
    for shuffleInd = 1:nShuffles
        if ~useGLM
            bothModelShuffle = fitlm(cat(2,shuffleArray(clusterIDs), leftTurn'),...
                neuronPoints, 'CategoricalVars',[1 2]);
        else
            bothModelShuffle = fitlm(cat(2,shuffleArray(clusterIDs), leftTurn'),...
                neuronPoints, 'CategoricalVars',[1 2], 'Distribution', 'Poisson',...
                'link', 'logit');
        end
        shuffleR2(neuron,shuffleInd) = bothModelShuffle.Rsquared.Adjusted;
    end
    
    %store
    %     clusterR2(neuron) = clusterModel.Rsquared.Adjusted;
    turnR2(neuron) = turnModel.Rsquared.Adjusted;
    bothR2(neuron) = bothModel.Rsquared.Adjusted;
    
    %display progress
    dispProgress('Neuron %d/%d',neuron,neuron,nNeurons);
end

%store
% out.clusterR2 = clusterR2;
out.turnR2 = turnR2;
out.bothR2 = bothR2;
out.shuffleR2 = shuffleR2;