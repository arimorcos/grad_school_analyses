function [acc] = validateClustering(dataCell,varargin)
%validateClustering.m Compares affinity propagation to k-means
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%
%ASM 4/15

segRanges = 0:80:480;
nBinsAvg = 4;
range = [0.5 0.75];
nPoints = 10;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'segranges'
                segRanges = varargin{argInd+1};
            case 'nbinsavg'
                nBinsAvg = varargin{argInd+1};
            case 'range'
                range = varargin{argInd+1};
        end
    end
end

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%get tracs
[~,traces] = catBinnedTraces(dataCell);

%get nNeurons
[nNeurons, ~, nTrials] = size(traces);

%%%%%%%%% Create matrix of values at each point in the maze

%initialize array
tracePoints = nan(nNeurons,nPoints,nTrials);

%fill in pre-seg
preSegInd = find(yPosBins < segRanges(1),1,'last') - nBinsAvg + 1:find(yPosBins < segRanges(1),1,'last');
tracePoints(:,1,:) = mean(traces(:,preSegInd,:),2);

%fill in each segment
for segInd = 1:length(segRanges)-1
    matchInd = find(yPosBins >= segRanges(segInd) & yPosBins < segRanges(segInd+1));
    binRange = round(range*length(matchInd));
    binRange = binRange + find(yPosBins >= segRanges(segInd),1,'first');
    tracePoints(:,segInd+1,:) = mean(traces(:,binRange(1):binRange(2),:),2);
end

% fill in early delay
offset = 4;
earlyDelayInd = find(yPosBins > segRanges(end),1,'first') + offset:...
    find(yPosBins > segRanges(end),1,'first') + offset + nBinsAvg;
tracePoints(:,8,:) = mean(traces(:,earlyDelayInd,:),2);

% fill in late delay
offset = 10;
lateDelayInd = find(yPosBins > segRanges(end),1,'first') + offset:...
    find(yPosBins > segRanges(end),1,'first') + offset + nBinsAvg;
tracePoints(:,9,:) = mean(traces(:,lateDelayInd,:),2);

% fill in turn
tracePoints(:,end,:) = mean(traces(:,end-nBinsAvg:end-1,:),2);

%%%%%%%%%%%% cluster
apClusterIDs = nan(nTrials,nPoints);
nClusters = nan(nPoints,1);
kmClusterIDs = nan(nTrials,nPoints);
for point = 1:nPoints
    %cluster using affinity propagation
    apClusterIDs(:,point) = apClusterNeuronalStates(squeeze(tracePoints(:,point,:)));
    
    %get number of clusters
    nClusters(point) = length(unique(apClusterIDs(:,point)));
    
    %cluster using k-means
    kmClusterIDs(:,point) = kmeans(squeeze(tracePoints(:,point,:))',nClusters(point));
end

%%%%%%%%%%%% find pairs within same cluster
acc = nan(nPoints,1);
for point = 1:nPoints
   
    %get pair list for each 
    apPairs = getPairList(apClusterIDs(:,point));
    kmPairs = getPairList(kmClusterIDs(:,point));
    
    %compare lists 
    pairMatch = ismember(apPairs,kmPairs,'rows');
    
    %get accuracy 
    acc(point) = sum(pairMatch)/size(apPairs,1);
    
end
end

function pairs = getPairList(in)

%get distance matrix
dist = squareform(pdist(in));

%find pairs with distance of 0 
samePair = find(dist == 0);

%get x and y indices 
[xInd,yInd] = ind2sub(size(dist),samePair);

%only keep pairs with xInd < yInd
keepInd = xInd < yInd;
xInd = xInd(keepInd);
yInd = yInd(keepInd);

%remove duplicate pairs 
pairs = cat(2,xInd,yInd);

end


