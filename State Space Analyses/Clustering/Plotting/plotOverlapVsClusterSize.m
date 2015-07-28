function plotOverlapVsClusterSize(overlapIndex,totalSize)
%plotOverlapVsClusterSize.m Plots overlap index as a function of cluster
%size for overlapping and non-overlapping neurons 
%
%INPUTS
%overlapIndex - nClusters x nClusters array of overlap values 
%totalSize - nClusters x nClusters matrix of total cluster size (symmetric)
%
%ASM 7/15

if ~iscell(overlapIndex)
    overlapIndex = {overlapIndex};
    totalSize = {totalSize};
end

%initialize 
diagOverlap = [];
diagSize = [];
offDiagOverlap = [];
offDiagSize = [];

for point = 1:length(overlapIndex)

%get diagonal of each 
diagOverlap = cat(1,diagOverlap,diag(overlapIndex{point}));
diagSize = cat(1,diagSize,diag(totalSize{point}));

%get off-diagonal of each 
lDiagInd = logical(tril(ones(size(totalSize{point})),-1));
offDiagOverlap = cat(1,offDiagOverlap,overlapIndex{point}(lDiagInd));
offDiagSize = cat(1,offDiagSize,totalSize{point}(lDiagInd));

end

%sort each 
[diagSize, diagSortOrder] = sort(diagSize);
diagOverlap = diagOverlap(diagSortOrder);
[offDiagSize, offDiagSortOrder] = sort(offDiagSize);
offDiagOverlap = offDiagOverlap(offDiagSortOrder);


%create figure
figH = figure;
axH = axes;
hold(axH, 'on');

%bin 
nBins = 10;
minVal = min(cat(1,diagSize,offDiagSize));
maxVal = max(cat(1,diagSize,offDiagSize));
binEdges = linspace(minVal,maxVal,nBins+1);
binnedOffDiag = nan(nBins,3);
binnedDiag = nan(nBins,3);
binnedDiagMeanSEM = nan(nBins,1);
binnedOffDiagMeanSEM = nan(nBins,1);
binVals = binEdges(1:end-1) + mean(diff(binEdges));
thresh = 3;
for bin = 1:nBins
    offDiagInd = offDiagSize >= binEdges(bin) & offDiagSize < binEdges(bin+1);
    diagInd = diagSize >= binEdges(bin) & diagSize < binEdges(bin+1);
    if sum(offDiagInd) >= thresh
        binnedOffDiag(bin,:) = prctile(offDiagOverlap(offDiagInd),[2.5 50 97.5]);
        binnedOffDiagMeanSEM(bin,1) = nanmean(offDiagOverlap(offDiagInd));
        binnedOffDiagMeanSEM(bin,2) = calcSEM(offDiagOverlap(offDiagInd));
    end
    if sum(diagInd) >= thresh
        binnedDiag(bin,:) = prctile(diagOverlap(diagInd),[2.5 50 97.5]);
        binnedDiagMeanSEM(bin,1) = nanmean(diagOverlap(diagInd));
        binnedDiagMeanSEM(bin,2) = calcSEM(diagOverlap(diagInd));
    end
end

%plot
% plotIntra = shadedErrorBar(binVals,binnedDiag(:,2),...
%     cat(2,binnedDiag(:,3)-binnedDiag(:,2),binnedDiag(:,2)-binnedDiag(:,1))','b',0.3);
% plotInter = shadedErrorBar(binVals,binnedOffDiag(:,2),...
%     cat(2,binnedOffDiag(:,3)-binnedOffDiag(:,2),binnedOffDiag(:,2)-binnedOffDiag(:,1))','r',0.3);
plotIntra = shadedErrorBar(binVals,binnedDiagMeanSEM(:,1),...
    binnedDiagMeanSEM(:,2),'b',0.3);
plotInter = shadedErrorBar(binVals,binnedOffDiagMeanSEM(:,1),...
    binnedOffDiagMeanSEM(:,2),'r',0.3);

%beuatify 
beautifyPlot(figH,axH);

%label
axH.XLabel.String = 'Effective Cluster Size';
axH.YLabel.String = 'Overlap Index';
