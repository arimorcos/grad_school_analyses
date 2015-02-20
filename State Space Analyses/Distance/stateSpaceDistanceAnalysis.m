function out = stateSpaceDistanceAnalysis(dataCell,conditions,usePCs)
%stateSpaceDistanceAnalysis.m Calculates distance between trials of different
%conditions in n-dimensional space and plots
%
%INPUTS
%dataCell - processed dataCell containing binned neuronal data
%conditions - 1 x 2 cell array containing conditions to compare. 1st
%   element will be the intra, second element will be inter. If second
%   element is empty, will compare to all.
%usePCs - use PCs instead of dF/F. Default is false
%varThresh - if using PCs, use minimum number of PCs to account for
%   variance = varThresh (between 0 and 1). Default is 0.75;
%
%OUTPUTS
%out - structure containing all output data
%
%ASM 11/13
if nargin < 3 || isempty(usePCs)
    usePCs = false;
end

%perform analysis
out = calcStateSpaceDistance(dataCell,conditions,usePCs);

%save conditions
out.conditions = conditions;

%plot
plotStateSpaceDistance(out);