function [deltaSegStart, deltaSegEnd, r] = getDeltaSegOffset(dataCell)
%getDeltaSegOffset.m Gets the offset for start and end 
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%ASM 7/15

nSeg = 6;

%get traces
[~,traces] = catBinnedTraces(dataCell);

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%get tracePoints
tracePoints = getMazePoints(traces,yPosBins);

%initialize
dists = cell(nSeg+1,1);

%get pairwise distance at each point from maze start to segment 6
for pointInd = 1:nSeg+1
    %get distances at each point
    dists{pointInd} = pdist(squeeze(tracePoints(:,pointInd,:))');
end

%get distances
segDist = tril(squareform(pdist([1:nSeg+1]')));

%loop through each deltaseg
deltaSegStart = cell(nSeg,1);
deltaSegEnd = cell(nSeg,1);
r = nan(nSeg,1);
for deltaSeg = 1:nSeg
    %get pairs which match
    [pair1,pair2] = ind2sub(size(segDist),find(segDist == deltaSeg));
    
    %concatenate all those points together
    deltaSegStart{deltaSeg} = cat(2,dists{pair2});
    deltaSegEnd{deltaSeg} = cat(2,dists{pair1});
    
    %corr
    corr = corrcoef(deltaSegStart{deltaSeg},deltaSegEnd{deltaSeg});
    r(deltaSeg) = corr(1,2);
end