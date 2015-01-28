function out = compareSegDistances(dataCell,varargin)
%compareSameSegDistances.m Compares distances between the same and
%different net evidence conditions holding the segment constant
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%Optional inputs specified by two element name and value
%
%segUnitRange - ranges of segments. Defaults to 0:80:480
%traceType - dFF or dGR
%binSize - bin size for binning.
%segBinRange - 1 x 2 range of bins to use expressed as a fraction. Default is [0.5 1]
%nShuffles - number of shuffles
%shouldShuffle - should shuffle or not
%
%OUTPUTS
%out - structure containing multiple fields
%
%   netEvSameSegDist - nNetEvConds x nNetEvConds x nSeg cell array
%       containing all data for each condition at each segment
%   segIDSameSegDist - nSegType x nSegType x nSeg cell array
%       containing all data for each condition at each segment
%   meanNetEvSameSegDist - nNetEvConds x nNetEvConds x nSeg array
%       containing mean distances for each condition at each segment
%   stdNetEvSameSegDist - nNetEvConds x nNetEvConds x nSeg array
%       containing standard deviation of distances for each condition at
%       each segment
%   meanSegIDSameSegDist - nSegType x nSegType x nSeg array
%       containing mean distances for each condition at each segment 
%   stdSegIDSameSegDist - nSegType x nSegType x nSeg array
%       containing standard deviation of distances for each condition at
%       each segment
%
%ASM 8/14

%% Initialize and process varargin
%initialize
segUnitRange = 0:80:480;
traceType = 'dFF';
segMeanRange = [0.2 0.9];
shouldShuffle = true;
nShuffles = 1e3;
distType = 'euclidean';
pcaThresh = 0.4;
filterOriginDist = ~true;
originFilterPerc = [5 95];
shouldShuffleSpeed = ~true;
nShufflesSpeed = 1e3;
filterRunSpeed = true;
runSpeedThreshMode = 'percentile';
runSpeedThresh = [10 90];

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'segunitrange'
                segUnitRange = varargin{argInd+1};
            case 'tracetype'
                traceType = varargin{argInd+1};
            case 'segmeanrange'
                segMeanRange = varargin{argInd+1};
            case 'shouldshuffle'
                shouldShuffle = varargin{argInd+1};
            case 'nshuffles'
                nShuffles = varargin{argInd+1};
            case 'disttype'
                distType = varargin{argInd+1};
            case 'pcathresh'
                pcaThresh = varargin{argInd+1};
            case 'filterorigindist'
                filterOriginDist = varargin{argInd+1};
            case 'originfilterperc'
                originFilterPerc = varargin{argInd+1};
            case 'shouldshufflespeed'
                shouldShuffleSpeed = varargin{argInd+1};
            case 'nshufflessped'
                nShufflesSpeed = varargin{argInd+1};
            case 'filterrunspeed'
                filterRunSpeed = varargin{argInd+1};
            case 'runspeedthresh'
                runSpeedThresh = varargin{argInd+1};
            case 'runspeedthreshmode'
                runSpeedThreshMode = varargin{argInd+1};
        end
    end
end

%% Extract segment traces and calculate distances

%extract segment traces
[segTraces,segId,netEv,segNum,numLeft,runSpeed] = extractSegmentTraces(dataCell,'segRanges',...
    segUnitRange,'traceType',traceType,'segMeanRange',segMeanRange,'pcaThresh',pcaThresh);

%distance to origin
distOrigin = getDistanceToOrigin(segTraces);

%if percentile filter
if filterOriginDist || filterRunSpeed
    
    %get percentiles
    percVals = prctile(distOrigin,originFilterPerc);
    
    %get indices of trials in between segments
    percInds = distOrigin >= percVals(1) & distOrigin <= percVals(2);
    highInds = distOrigin > percVals(2);
    lowInds = distOrigin < percVals(1);
    
    %get runSpeed
    runSpeedUsed = runSpeed(percInds);
    runSpeedHigh = runSpeed(highInds);
    runSpeedLow = runSpeed(lowInds);
    
    %shuffle if should
    if shouldShuffleSpeed
        %initialize
        nUsed = sum(percInds);
        nHigh = sum(highInds);
        nLow = sum(lowInds);
        nComp = length(distOrigin);
        out.shuffleRunSpeedUsed = zeros(nUsed,nShufflesSpeed);
        out.shuffleRunSpeedHigh = zeros(nHigh,nShufflesSpeed);
        out.shuffleRunSpeedLow = zeros(nLow,nShufflesSpeed);
        for shuffleInd = 1:nShufflesSpeed
            %generate each indices
            randInd = randsample(nComp,nComp);
            usedIndTemp = randInd(1:nUsed);
            highIndTemp = randInd(nUsed+1:nUsed+nHigh);
            lowIndTemp = randInd(nUsed+nHigh+1:end);
            
            %get values
            out.shuffleRunSpeedUsed(:,shuffleInd) = runSpeed(usedIndTemp);
            out.shuffleRunSpeedHigh(:,shuffleInd) = runSpeed(highIndTemp);
            out.shuffleRunSpeedLow(:,shuffleInd) = runSpeed(lowIndTemp);
            
        end
    end
    
    %filter based on runspeed
    if filterRunSpeed
        switch lower(runSpeedThreshMode)
            case 'absolute'
                if length(runSpeedThresh) == 1
                    percInds = runSpeed < runSpeedThresh;
                elseif length(runSpeedThresh) == 2
                    percInds = runSpeed >= runSpeedThresh(1) & runSpeed < runSpeedThresh(2);
                end
            case 'percentile'
                runSpeedPercVals = prctile(runSpeed,runSpeedThresh);
                if length(runSpeedThresh) == 1
                    percInds = runSpeed < runSpeedPercVals;
                elseif length(runSpeedThresh) == 2
                    percInds = runSpeed >= runSpeedPercVals(1) & runSpeed < runSpeedPercVals(2);
                end
        end
        
    end
    
    %filter out trials
    out.segTracesAll = segTraces;
    out.segIdAll = segId;
    out.netEvAll = netEv;
    out.segNumAll = segNum;
    out.numLeftAll = numLeft;
    out.runSpeedAll = runSpeed;
    segTraces = segTraces(:,percInds);
    segId = segId(percInds);
    netEv = netEv(percInds);
    segNum = segNum(percInds);
    numLeft = numLeft(percInds);
    runSpeed = runSpeed(percInds);
    
end

%calculate distances
[dist] = calcSegActivityDistance(segTraces,distType);

%set values on diagonal to nan
dist(logical(eye(size(dist)))) = NaN;


%% Calculate intra and inter distances for different conditions with the same segment

%get unique net evidence conditions
netEvConds = unique(netEv);
nNetEvConds = length(netEvConds);

%get unique segId
segIdConds = unique(segId);
nSegIds = length(segIdConds);

%get nSeg
nSeg = length(unique(segNum));

[netEvSameSegDist,segIDSameSegDist] = calcSameSegInfo(nSeg,nSegIds,...
    segIdConds,netEvConds,nNetEvConds,dist,segId,netEv,segNum);

%take mean and std of each cell
meanNetEvSameSegDist = cellfun(@nanmean,netEvSameSegDist);
stdNetEvSameSegDist = cellfun(@nanstd,netEvSameSegDist);
meanSegIDSameSegDist = cellfun(@nanmean,segIDSameSegDist);
stdSegIDSameSegDist = cellfun(@nanstd,segIDSameSegDist);

%create indices matrices for diagonal and off-diagonal elements
indicesMatNetEv = ones(size(meanNetEvSameSegDist,1),size(meanNetEvSameSegDist,2));
offDiagIndNetEv = logical(tril(indicesMatNetEv,-1)); %get off diagonal indices
diagIndNetEv = logical(eye(size(meanNetEvSameSegDist,1),size(meanNetEvSameSegDist,2))); %get on diagonal indices
indicesMatSegID = ones(size(meanSegIDSameSegDist,1),size(meanSegIDSameSegDist,2));
offDiagIndSegID = logical(tril(indicesMatSegID,-1)); %get off diagonal indices
diagIndSegID = logical(eye(size(meanSegIDSameSegDist,1),size(meanSegIDSameSegDist,2))); %get on diagonal indices

%initialize arrays to store
intraNetEvSameSegDistAll = cell(nSeg,1);
interNetEvSameSegDistAll = cell(nSeg,1);
intraSegIDSameSegDistAll = cell(nSeg,1);
interSegIDSameSegDistAll = cell(nSeg,1);

%get distances for net evidence 
for segInd = 1:nSeg %for each segment
    %get all diagonal or off-diagonal elements
    intraNetEvSameSegDistAll{segInd} = netEvSameSegDist(find(diagIndNetEv) + (segInd-1)*numel(diagIndNetEv));
    interNetEvSameSegDistAll{segInd} = netEvSameSegDist(find(offDiagIndNetEv) + (segInd-1)*numel(offDiagIndNetEv));
    intraSegIDSameSegDistAll{segInd} = segIDSameSegDist(find(diagIndSegID) + (segInd-1)*numel(diagIndSegID));
    interSegIDSameSegDistAll{segInd} = segIDSameSegDist(find(offDiagIndSegID) + (segInd-1)*numel(offDiagIndSegID));
    
    %remove nans
    intraNetEvSameSegDistAll{segInd} = intraNetEvSameSegDistAll{segInd}(...
        ~cellfun(@isempty,intraNetEvSameSegDistAll{segInd}));
    interNetEvSameSegDistAll{segInd} = interNetEvSameSegDistAll{segInd}(...
        ~cellfun(@isempty,interNetEvSameSegDistAll{segInd}));
    intraSegIDSameSegDistAll{segInd} = intraSegIDSameSegDistAll{segInd}(...
        ~cellfun(@isempty,intraSegIDSameSegDistAll{segInd}));
    interSegIDSameSegDistAll{segInd} = interSegIDSameSegDistAll{segInd}(...
        ~cellfun(@isempty,interSegIDSameSegDistAll{segInd}));
    
    %concatenate all values
    intraNetEvSameSegDistAll{segInd} = cat(1,intraNetEvSameSegDistAll{segInd}{:});
    interNetEvSameSegDistAll{segInd} = cat(1,interNetEvSameSegDistAll{segInd}{:});
    intraSegIDSameSegDistAll{segInd} = cat(1,intraSegIDSameSegDistAll{segInd}{:});
    interSegIDSameSegDistAll{segInd} = cat(1,interSegIDSameSegDistAll{segInd}{:});
end

%take mean/std of inter/intra values
meanIntraNetEvSameSegDist = cellfun(@nanmean,intraNetEvSameSegDistAll);
meanInterNetEvSameSegDist = cellfun(@nanmean,interNetEvSameSegDistAll);
meanDiffNetEvSameSegDist = meanInterNetEvSameSegDist - meanIntraNetEvSameSegDist;
stdIntraNetEvSameSegDist = cellfun(@nanstd,intraNetEvSameSegDistAll);
stdInterNetEvSameSegDist = cellfun(@nanstd,interNetEvSameSegDistAll);
meanIntraSegIDSameSegDist = cellfun(@nanmean,intraSegIDSameSegDistAll);
meanInterSegIDSameSegDist = cellfun(@nanmean,interSegIDSameSegDistAll);
meanDiffSegIDSameSegDist = meanInterSegIDSameSegDist - meanIntraSegIDSameSegDist;
stdIntraSegIDSameSegDist = cellfun(@nanstd,intraSegIDSameSegDistAll);
stdInterSegIDSameSegDist = cellfun(@nanstd,interSegIDSameSegDistAll);

%% get different difficulty values
%get number of difficulties
uniqueDiff = unique(numLeft);
nDiff = length(uniqueDiff);

%initialize
diffDistances = cell(nSeg,nDiff);
originDiffDistances = cell(nSeg,nDiff);

%for each segment
for segInd = 1:nSeg
    for diffInd = 1:nDiff %for each difficulty
        
        %get indices
        tempInds = segNum==segInd & numLeft==uniqueDiff(diffInd);
        
        %get all combinations
        allCombInds = allcomb(find(tempInds),find(tempInds));
        
        %convert to linear indices
        linInds = sub2ind(size(dist),allCombInds(:,1),allCombInds(:,2));
        
        %get distances
        diffDistances{segInd,diffInd} = dist(linInds);
        
        %get distances to origin
        originDiffDistances{segInd,diffInd} = distOrigin(tempInds);
    end
end
    
%% Get shuffled distances for segments

shuffledMeansDiffSameSegNetEv = zeros(nSeg,nShuffles);
shuffledMeansDiffSameSegSegId = zeros(nSeg,nShuffles);

%get same segment number of values for intra and inter
nIntra = cellfun(@length,intraNetEvSameSegDistAll);
nInter = cellfun(@length,interNetEvSameSegDistAll);


%combine intra and inter for same seg
allNetEv = arrayfun(@(x) cat(1,intraNetEvSameSegDistAll{x},...
    interNetEvSameSegDistAll{x}),1:nSeg,'UniformOutput',false);
allSegID = arrayfun(@(x) cat(1,intraSegIDSameSegDistAll{x},...
    interSegIDSameSegDistAll{x}),1:nSeg,'UniformOutput',false);

if shouldShuffle
    for shuffleInd = 1:nShuffles
        
        %display progress
        dispProgress('Running shuffle...%04d/%04d',shuffleInd,shuffleInd,nShuffles);
        
        %%%%%%%%%%%% SAME SEGMENTS %%%%%%%%%%%%%%   
        %loop through each segment
        for segInd = 1:nSeg
            %resample from intra and inter for same segment
            shuffleIntraInd = randsample(length(allNetEv{segInd}),nIntra(segInd)); %ake intra indices
%             shuffleInterInd = randsample(nIntra(segInd)+nInter(segInd),nInter(segInd));
            shuffleInterInd = setdiff(1:length(allNetEv{segInd}),shuffleIntraInd)';
            tempIntraNet = allNetEv{segInd}(shuffleIntraInd);
            tempInterNet = allNetEv{segInd}(shuffleInterInd);
            tempIntraSeg = allSegID{segInd}(shuffleIntraInd);
            tempInterSeg = allSegID{segInd}(shuffleInterInd);
            
            %take means
            shuffledMeansDiffSameSegNetEv(segInd,shuffleInd) = ...
                nanmean(tempInterNet) - nanmean(tempIntraNet);
            shuffledMeansDiffSameSegSegId(segInd,shuffleInd) = ...
                nanmean(tempInterSeg) - nanmean(tempIntraSeg);
        end
        
        %%%%%%%%%%%%%%% DIFFERENT SEGMENTS %%%%%%%%%%%%
        %perform calculation for different segments
        
        
        %calculate means for different segments
        
    end
end

%% Store outputs
%same segment
out.meanNetEvSameSegDist = meanNetEvSameSegDist;
out.stdNetEvSameSegDist = stdNetEvSameSegDist;
out.meanSegIDSameSegDist = meanSegIDSameSegDist;
out.stdSegIDSameSegDist = stdSegIDSameSegDist;
out.netEvSameSegDist = netEvSameSegDist;
out.segIDSameSegDist = segIDSameSegDist;
out.meanIntraNetEvSameSegDist = meanIntraNetEvSameSegDist;
out.meanInterNetEvSameSegDist = meanInterNetEvSameSegDist;
out.stdIntraNetEvSameSegDist = stdIntraNetEvSameSegDist;
out.stdInterNetEvSameSegDist = stdInterNetEvSameSegDist;
out.meanIntraSegIDSameSegDist = meanIntraSegIDSameSegDist;
out.meanInterSegIdSameSegDist = meanInterSegIDSameSegDist;
out.stdIntraSegIDSameSegDist = stdIntraSegIDSameSegDist;
out.stdInterSegIDSameSegDist = stdInterSegIDSameSegDist;
out.meanDiffSegIDSameSegDist = meanDiffSegIDSameSegDist;
out.meanDiffNetEvSameSegDist = meanDiffNetEvSameSegDist;
out.nSeg = nSeg;
out.intraNetEvSameSegDistAll = intraNetEvSameSegDistAll;
out.interNetEvSameSegDistAll = interNetEvSameSegDistAll;
out.intraSegIDSameSegDistAll = intraSegIDSameSegDistAll;
out.interSegIDSameSegDistAll = interSegIDSameSegDistAll;
out.uniqueDiff = uniqueDiff;
out.diffDistances = diffDistances;
out.netEvConds = netEvConds;
out.segIdConds = segIdConds;
if filterOriginDist
    out.originDiffDistances = originDiffDistances;
    out.distOrigin = distOrigin;
    out.runSpeedUsed = runSpeedUsed;
    out.runSpeedHigh = runSpeedHigh;
    out.runSpeedLow = runSpeedLow;
    out.runSpeedAll = runSpeed;
end

%shuffle
if shouldShuffle
    out.shuffledMeansDiffSameSegNetEv = shuffledMeansDiffSameSegNetEv;
    out.shuffledMeansDiffSameSegSegId = shuffledMeansDiffSameSegSegId;
end


end 

function [netEvSameSegDist,segIDSameSegDist] = calcSameSegInfo(nSeg,nSegIds,...
    segIdConds,netEvConds,nNetEvConds,dist,segId,netEv,segNum)

%initialize arrays
netEvSameSegDist = cell(nNetEvConds,nNetEvConds,nSeg);
segIDSameSegDist = cell(nSegIds,nSegIds,nSeg);

%loop through each segment and extract proper distances
for segInd = 1:nSeg %for each segment number
    
    %find indices which match segment
    segTrialInds = segNum == segInd;
    
    %get subset of distance matrix for same segment
    distSub = dist(segTrialInds,segTrialInds);
    
    %get subset of segId and netEv which match same segment
    segIdSub = segId(segTrialInds);
    netEvSub = netEv(segTrialInds);
    
    %loop through each net evidence condition and find combinations
    for evCondRow = 1:nNetEvConds %for each net evidence row
        
        %find trials which match evCondRow
        rowTrials = find(netEvSub == netEvConds(evCondRow));
        if isempty(rowTrials)
            continue;
        end
        for evCondColumn = 1:evCondRow %for each net evidence column up to the current row
            
            %find trials which match evCondRow
            columnTrials = find(netEvSub == netEvConds(evCondColumn));
            
            %check for empty inputs
            if isempty(rowTrials) || isempty(columnTrials)
                continue;
            end
            
            %get all combinations of row and column
            allCombTrials = allcomb(rowTrials,columnTrials);
%             allCombTrials = cat(1,allCombTrials,allcomb(columnTrials,rowTrials));%add on flipped row and column
            
            %get linear indices which match row and column combinations
            trialIndices = sub2ind(size(distSub),allCombTrials(:,1),allCombTrials(:,2));
%             trialIndices = sub2ind(size(distSub),rowTrials,columnTrials);
            
            %only take unique trialIndices
            trialIndices = unique(trialIndices);
            
            %store distance values 
            netEvSameSegDist{evCondRow,evCondColumn,segInd} = distSub(trialIndices);
        end
    end
    
    %loop through segment ID conditiosn 
    for segIDRow = 1:nSegIds %for each segID row
        
        %find trials which match segIDRow
        rowTrials = find(segIdSub == segIdConds(segIDRow));
        
        for segIDColumn = 1:segIDRow %for each segID column
            
            %find trials which match segID
            columnTrials = find(segIdSub == segIdConds(segIDColumn));
            
            %check for empty inputs
            if isempty(rowTrials) || isempty(columnTrials)
                continue;
            end
            
            %get all combinations of row and column
            allCombTrials = allcomb(rowTrials,columnTrials);
            allCombTrials = cat(1,allCombTrials,allcomb(columnTrials,rowTrials));%add on flipped row and column
            
            %get linear indices which match row and column combinations
            trialIndices = sub2ind(size(distSub),allCombTrials(:,1),allCombTrials(:,2));
            
            %only take unique trialIndices
            trialIndices = unique(trialIndices);
            
            %store distance values 
            segIDSameSegDist{segIDRow,segIDColumn,segInd} = distSub(trialIndices);
        end
    end
    
end
end

