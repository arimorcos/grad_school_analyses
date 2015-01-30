function sepVectors = getTrajSepVectors(trajSep,vectorRange,binNums)
%getTrajSepVectors.m Calculates segVectors based on trajectory separations 
%
%INPUTS
%trajSep - trajectory separation matrix output by calcTrajSeparation
%binNums - 1 x nSeg + 1 array of binNumbers for start and stop of each
%   segment
%vectorRange - 1 x 2 array of fraction start and end bin for vector
%   calculation. Must be between 0 and 1
%
%OUTPUTS
%sepVectors - nPairs x nSeg array of separation vectors
%
%ASM 1/15

offset = 1;

if nargin < 3 || isempty(binNums)
    binNums = [10 26 42 58 74 90 106];
end

if nargin < 2 || isempty(vectorRange)
    vectorRange = [0 1];
end

%get nPairs, nSeg, and nDim
nPairs = size(trajSep,1);
nSeg = length(binNums) - 1;

%get nBinsPerSeg
nBinsPerSeg = unique(diff(binNums));
assert(length(nBinsPerSeg) == 1,'Each segment must have an equivalent number of bins');

%get binRange for vectors 
vectorBinRange = round(vectorRange*nBinsPerSeg);
binRange = bsxfun(@plus,binNums',vectorBinRange) - offset;

%reshape traces into nDim x nSeg x nPairs
sepVectors = nan(nPairs, nSeg);
for segNum = 1:nSeg
    
    %extract and store
    sepVectors(:, segNum) = trajSep(:,binRange(segNum,2)) - trajSep(:,binRange(segNum,1));
    
end