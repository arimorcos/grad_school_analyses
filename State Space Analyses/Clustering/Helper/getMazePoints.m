function tracePoints = getMazePoints(traces,yPosBins,range)
%getMazePoints.m Generates averages at 10 points throughout the maze.
%Pre-seg 1, Seg 1-6, Early Delay, Late Delay, and Turn
%
%INPUTS
%traces - nNeurons x nBins x nTrials array
%
%OUTPUTS
%tracePoints - nNeurons x 10 x nTrials array
%
%ASM 4/15

segRanges = 0:80:480;
nBinsAvg = 4;
if nargin < 3 || isempty(range)
    range = [0.5 0.75];
end

%get size
[nNeurons,~,nTrials] = size(traces);
nPoints = 10;

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