function out = calcOverlapCorrCoefVsDeltaPLeft(dataCell, clusterIDs, cMat)
%calcOverlapCorrCoefVsDeltaPLeft.m Calcualtes the pairwise overlap and
%correlation coefficients between pairs of clusters and outputs the
%corresponding difference in p(left)
%
%INPUTS 
%dataCell - dataCell containing imaging data 
%
%OUTPUTS
%out - structure containing the following: 
%   overlap - nEpochs x 1 cell array containgin nPairs x 1 overlap indices 
%   corr - nEpochs x 1 cell array containgin nPairs x 1 correlation 
%       coefficients
%   deltaPLeft - nEpochs x 1 cell array containgin nPairs x 1 absolute 
%       difference in p(left)
%
%ASM 10/15

%cluster if necessary 
if nargin <= 1 || isempty(cMat) || isempty(clusterIDs)
    [~, cMat, clusterIDs, ~] = getClusteredMarkovMatrix(dataCell);
end

% calculate overlap index 
overlapIndexMat = calculateClusterOverlap(dataCell,clusterIDs,cMat,...
    'nBootstrap',1, 'zthresh', 0.3);

% calculate correlation coefficient 
clusterCorrMat = calculateClusterCorrelation(dataCell,clusterIDs,cMat);

% get delta p left for each cluster 
nPoints = size(clusterIDs, 2);
deltaPLeftMat = cell(nPoints, 1);
for point = 1:nPoints
    
    tempPLeft = cMat.leftTurn{point};
    deltaPLeftMat{point} = squareform(pdist(tempPLeft, 'euclidean'));
end

% loop through each point and create arrays 
deltaPLeft = cell(nPoints,1);
clusterCorr = cell(nPoints,1);
overlapIndex = cell(nPoints,1);
for point = 1:nPoints
    
    %create indices 
    indexMat = true(size(deltaPLeftMat{point}));
    lTriInd = tril(indexMat, -1);
    
    %get each 
    deltaPLeft{point} = deltaPLeftMat{point}(lTriInd);
    clusterCorr{point} = clusterCorrMat{point}(lTriInd);
    overlapIndex{point} = overlapIndexMat{point}(lTriInd);
    
end

%store 
out.deltaPLeft = deltaPLeft;
out.corr = clusterCorr;
out.overlap = overlapIndex;