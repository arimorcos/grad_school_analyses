function [binVec, startVec] = getBinnedVectors(dataCell,varargin)
%getBinnedVectors.m Extracts binned diff vectors from a dataCell for a
%given traceType 
%
%INPUTS
%dataCell - dataCell containing binned imaging data
%
%OPTIONAL INPUTS
%traceType - trace to use 
%whichFactorSet - factor set to use 
%binRange - range of bins to use
%
%OUTPUTS
%binVec - nNeurons/nFactors x (nBins - 1) x nTrials array of change in vector
%   position for every bin 
%startVec - nNeurons/nFactors x nTrials array of starting locations 
%
%ASM 1/15



%assert that contains only binned imaging data
assert(all(getCellVals(dataCell,'imaging.imData')),'dataCell must contain only imaging data');
assert(isfield(dataCell{1}.imaging,'binnedDFFTraces'),'Imaging data must be binned');

%process varargin
whichFactorSet = 2;
traceType = 'dffFactor';
binRange = [-20 620];

if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'whichfactorset'
                whichFactorSet = varargin{argInd+1};
            case 'tracetype'
                traceType = varargin{argInd+1};
            case 'binrange'
                binRange = varargin{argInd+1};
        end
    end
end

%extract traces 
switch lower(traceType)
    case 'dfffactor'
        traces = catBinnedFactors(dataCell,whichFactorSet);
    case 'dff'
        [~,traces] = catBinnedTraces(dataCell);
    otherwise 
        error('Can''t process traceType: %s',traceType);
end

%filter based on binRange
binRangeInBinNum(1) = find(binRange(1) <= dataCell{1}.imaging.yPosBins,1,'first');
binRangeInBinNum(2) = find(binRange(2) >= dataCell{1}.imaging.yPosBins,1,'last');

%crop traces to binRange 
traces = traces(:,binRangeInBinNum(1):binRangeInBinNum(2),:);

%take diff
binVec = diff(traces, 1, 2);

%get start location
startVec = squeeze(traces(:,1,:));