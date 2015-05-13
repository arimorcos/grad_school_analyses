function [deltaPointNeuron,deltaPointBehavior,deltaPointBehavNeur] = ...
    getAllDeltaPoint(dataCell,varargin)

shouldShuffle = true;
nShuffles = 100;
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'shouldshuffle'
                shouldShuffle = varargin{argInd+1};
            case 'nshuffles'
                nShuffles = varargin{argInd+1};
        end
    end
end

%get real values 
[~,~,deltaPointBehavNeur] = quantifyBehavToNeuronalClusterProb(dataCell);
[~,~,deltaPointNeuron] = quantifyInternalVariability(dataCell);
[~,~,deltaPointBehavior] = quantifyInternalVariability(dataCell,'useBehavior',true,varargin{:});

if ~shouldShuffle
    return;
end

%get nDelta
nDelta = length(deltaPointNeuron.nSTDAboveMedian);
% nDelta = 9;

%get differences 
neur_Behav_Diff = nan(nShuffles,nDelta);
neur_BehavNeur_Diff = nan(nShuffles,nDelta);
behav_BehavNeur_Diff = nan(nShuffles,nDelta);
for shuffleInd = 1:nShuffles 
    [~,~,tempBehavNeur] = quantifyBehavToNeuronalClusterProb(dataCell,...
        'shuffleInitial',true);
    [~,~,tempNeuron] = quantifyInternalVariability(dataCell,...
        'shuffleInitial',true);
    [~,~,tempBehavior] = quantifyInternalVariability(dataCell,...
        'useBehavior',true,'shuffleInitial',true);
    
    %get differences 
    neur_Behav_Diff(shuffleInd,:) = (tempNeuron.nSTDAboveMedian - ...
        tempBehavior.nSTDAboveMedian)';
    neur_BehavNeur_Diff(shuffleInd,:) = (tempNeuron.nSTDAboveMedian - ...
        tempBehavNeur.nSTDAboveMedian(2:end))';
    behav_BehavNeur_Diff(shuffleInd,:) = (tempBehavNeur.nSTDAboveMedian(2:end) - ...
        tempBehavior.nSTDAboveMedian)';
    
    %display progress 
    fprintf('Overall shuffle %d/%d\n',shuffleInd,nShuffles);
end

%store 
deltaPointNeuron.diffs.neur_Behav_Diff = neur_Behav_Diff;
deltaPointNeuron.diffs.behav_BehavNeur_Diff = behav_BehavNeur_Diff;
deltaPointNeuron.diffs.neur_BehavNeur_Diff = neur_BehavNeur_Diff;