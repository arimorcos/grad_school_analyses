function acc = getLeftRightAccuracyNeuronFallout(dataCell, sortOrder, ...
    shuffleTraces, increment, useClass)
%getLeftRightAccuracyNeuronFallout.m Calculates svm accuracy at predicting
%left-right turn with increasing number of neurons. Adds neurons according
%to the sortOrder array starting from top.
%
%INPUTS 
%dataCell - dataCell containing imaging data 
%sortOrder - nNeurons x 1 array containing order to add neurons in 
%
%OUTPUTS
%acc - nNeurons x nBins array of svm accuracy
%
%ASM 7/15

useDeconv = true;

if nargin < 5 || isempty(useClass)
    useClass = [];
end

if nargin < 4 || isempty(increment)
    increment = 1;
end
if nargin < 3 || isempty(shuffleTraces)
    shuffleTraces = false;
end

if shuffleTraces
    traces = breakTrialAssociationForClassifier(dataCell, useDeconv);
else
    %get traces
    if useDeconv
        traces = catBinnedDeconvTraces(dataCell);
    else
        [~,traces] = catBinnedTraces(dataCell);
    end
end

%get nNeurons
nNeurons = size(traces,1);

%crop traces
traces = traces(:,2:end-1,:);

%check that sortOrder matches
assert(nNeurons == length(sortOrder),'sortOrder must match nNeurons');

%get leftTurns
if isempty(useClass)
    leftTurns = getCellVals(dataCell,'result.leftTurn');
else
    leftTurns = useClass;
end

%get nBins 
nBins = size(traces,2);

%initialize 
acc = nan(nNeurons, nBins);

%loop through each neuron and add 
for neuronCount = 2:increment:nNeurons
    
    %get svm accuracy 
    acc(neuronCount,:) = getSVMAccuracy(traces(sortOrder(1:neuronCount),:,:),...
        leftTurns,'kfold',1,'cParam',2,'gamma',0.04);
    
    %display progress
%     dispProgress('Getting accuracy %d/%d',neuronCount, neuronCount, nNeurons);
end