function [deltaSegStart, deltaVec, r] = getDeltaSegVectors(dataCell)
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

%get vector distances for each pair of forward points
vecDists = cell(nSeg+1,nSeg+1);
for startPoint = 1:nSeg
    for endPoint = startPoint+1:nSeg+1
        
        %get vecttor 
        vec = squeeze(tracePoints(:,endPoint,:) - tracePoints(:,startPoint,:));
        
        %get pairwise vector distance 
        vecDists{startPoint,endPoint} = pdist(vec');
        
    end
end


%get distances
segDist = triu(squareform(pdist((1:nSeg+1)')));

%loop through each deltaseg
deltaSegStart = cell(nSeg,1);
deltaVec = cell(nSeg,1);
r = nan(nSeg,1);
for deltaSeg = 1:nSeg
    %get pairs which match
    [pair1,~] = ind2sub(size(segDist),find(segDist == deltaSeg));
    
    %concatenate all those points together
    deltaSegStart{deltaSeg} = cat(2,dists{pair1});
    deltaVec{deltaSeg} = cat(2,vecDists{segDist==deltaSeg});
    
    %corr
    corr = corrcoef(deltaSegStart{deltaSeg},deltaVec{deltaSeg});
    r(deltaSeg) = corr(1,2);
end