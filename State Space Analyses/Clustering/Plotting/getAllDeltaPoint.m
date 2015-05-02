function [deltaPointNeuron,deltaPointBehavior,deltaPointBehavNeur] = ...
    getAllDeltaPoint(dataCell,varargin)


if ~isempty(varargin)
    [~,~,deltaPointBehavNeur] = quantifyBehavToNeuronalClusterProb(dataCell,varargin{:});
    [~,~,deltaPointNeuron] = quantifyInternalVariability(dataCell,varargin{:});
    [~,~,deltaPointBehavior] = quantifyInternalVariability(dataCell,'useBehavior',true,varargin{:});
else
    [~,~,deltaPointBehavNeur] = quantifyBehavToNeuronalClusterProb(dataCell);
    [~,~,deltaPointNeuron] = quantifyInternalVariability(dataCell);
    [~,~,deltaPointBehavior] = quantifyInternalVariability(dataCell,'useBehavior',true);
end