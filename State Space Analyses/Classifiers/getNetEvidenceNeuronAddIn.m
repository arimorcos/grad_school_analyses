function classifierOut = getNetEvidenceNeuronAddIn(dataCell, ...
    sortOrder, shuffleTraces, increment)
%getNetEvidenceNeuronAddIn.m Calculates svm accuracy at predicting
%net evidence turn with increasing number of neurons. Adds neurons according
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
if nargin < 4 || isempty(increment)
    increment = 1;
end
if nargin < 3 || isempty(shuffleTraces)
    shuffleTraces = false;
end

if shuffleTraces
    traces = breakTrialAssociationForClassifier(dataCell);
else
    %get traces
    [~,traces] = catBinnedTraces(dataCell);
end

%get nNeurons
nNeurons = size(traces,1);

%crop traces
% traces = traces(:,2:end-1,:);

%check that sortOrder matches
assert(nNeurons == length(sortOrder),'sortOrder must match nNeurons');

%initialize 
classifierOut = cell(nNeurons, 1);

%loop through each neuron and add 
for neuronCount = 2:increment:nNeurons
    
    classifierOut{neuronCount} = classifyNetEvGroupSegSVM(dataCell,'whichNeurons',...
        sortOrder(1:neuronCount));
    
end