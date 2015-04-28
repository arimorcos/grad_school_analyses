function [r2,pVal] = getDeltaSegVectorSig(dataCell)

%plotDeltaSegOffset.m Plots the delta segment offset
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%ASM 4/15

nSeg = 6;

if nargin < 3 || isempty(binPoints)
    binPoints = true;
end

if nargin < 2 || isempty(whichPlots)
    whichPlots = 1:nSeg;
end

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
for deltaSeg = 1:nSeg
    %get pairs which match
    [pair1,~] = ind2sub(size(segDist),find(segDist == deltaSeg));
    
    %concatenate all those points together
    deltaSegStart{deltaSeg} = cat(2,dists{pair1});
    deltaVec{deltaSeg} = cat(2,vecDists{segDist==deltaSeg});
end

nPlots = nSeg;
r2 = nan(nPlots,1);
pVal = nan(nPlots,1);

%loop through ecah plot
for plotInd = 1:nPlots

%calculate correlation coefficient
    [corr,p] = corrcoef(deltaSegStart{whichPlots(plotInd)},deltaVec{whichPlots(plotInd)});
    r2(plotInd) = corr(2,1)^2;
    pVal(plotInd) = p(2,1);
end
    