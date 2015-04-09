function [nClusters] = validateNClustersAP(dataCell,perc,varargin)
%validateClustering.m Compares affinity propagation to k-means
%
%INPUTS
%dataCell - dataCell containing imaging data
%perc - list of percentile values to try
%
%OUTPUTS
%nClusters - 1 x nPercVals containing 
%

%ASM 4/15

segRanges = 0:80:480;
nBinsAvg = 4;
range = [0.5 0.75];
nPoints = 10;
whichPoint = 5;

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
            case 'whichpoint'
                whichPoint = varargin{argInd+1};
        end
    end
end

if nargin < 2 || isempty(perc)
    perc = 1:1:100;
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
%crop to point 
inputData = squeeze(tracePoints(:,whichPoint,:));

%get nPerc
nPerc = length(perc);

nClusters = nan(nPerc,1);
for percVal = 1:nPerc
    %cluster using affinity propagation
    tempClusterIDs = apClusterNeuronalStates(inputData, perc(percVal));
    
    %store nClusters
    nClusters(percVal) = length(unique(tempClusterIDs));  
    
    %display progress
    dispProgress('Calculating clusters for percentile value %d/%d',percVal,percVal,nPerc);
end

%plot 
figure;
axH = axes;
plotH = plot(perc,nClusters);
plotH.Marker = 'o';
plotH.LineStyle = '-';
plotH.Color = 'k';
axH.FontSize = 20;
axH.YLabel.String = '# Clusters';
axH.XLabel.String = 'Starting preference percentile';





