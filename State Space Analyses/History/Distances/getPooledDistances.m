function [varargout] =...
    getPooledDistances(dataCell,varargin)
%getPooledDistances.m Pools different net evidence condition history
%results to establish a better estimate of accuracy. Finds triplets with
%with one non-matching evidence and calculates accuracy at rpedicting
%segments 1 and 2 during segment 3. Uses all triplets, regardless of which
%segments they come from. To compensate for different net evidence
%conditions, matches proportion of trials with different net evidence
%conditions prior to triplet. For example, for the triplet LRR starting on
%the 2nd segment, procedure ensures that an equal number of trials have R
%and L as the first segment.
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OPTIONAL INPUTS
%packetSize - length of packet in segments. Default is a triplet (value of 3).
%nShuffles - number of shuffles to perform
%trialMin - minimum number of trials in a group
%poolAllSeg - pool all the packets, regardless of which segment it comes
%   from
%separateLeftRight - separate left and right outputs
%mode - svm or info
%whichFactor - for info, which number of factors to use.
%predictFuture - predict past segments or future segments. Default is false
%
%OUTPUTS
%
%
%ASM 12/14

%process varargin
packetSize = 2;
nShuffles = 100;
shouldPlot = true;
separateLeftRight = false;
whichFactor = 2;
predictFuture = false;
traceType = 'dFF';

if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'packetsize'
                packetSize = varargin{argInd+1};
            case 'nshuffles'
                nShuffles = varargin{argInd+1};
            case 'separateleftright'
                separateLeftRight = varargin{argInd+1};
            case 'whichfactor'
                whichFactor = varargin{argInd+1};
            case 'predictfuture'
                predictFuture = varargin{argInd+1};
            case 'tracetype'
                traceType = varargin{argInd+1};
            case 'shouldplot'
                shouldPlot = varargin{argInd+1};
        end
    end
end

%get maze patterns
mazePatterns = getMazePatterns(dataCell);

%get net evidence
netEvidence = getNetEvidence(dataCell);

%get nSeg
nSeg = size(mazePatterns,2);

%generate packet combinations
packetOptions = repmat({[0 1]},packetSize,1); %create cell array with proper number of packet options
packetComb = allcomb(packetOptions{:}); %get all combinations
leftPackets = packetComb(logical(packetComb(:,end)),:);
rightPackets = packetComb(~logical(packetComb(:,end)),:);

%flip packets if future
if predictFuture
    leftPackets = fliplr(leftPackets);
    rightPackets = fliplr(rightPackets);
end

%initialize
interLeft = cell(1,packetSize-1);
intraLeft = cell(size(interLeft));
intraRight = cell(size(interLeft));
interRight = cell(size(interLeft));

%get net evidence
netEvidence = getNetEvidence(dataCell);

%loop through each packet/segment number combination
for segInd = 1:nSeg - packetSize - 1
    
    %extract portion of maze which is relevant
    packetPatternSub = mazePatterns(:,segInd:segInd + packetSize - 1);
    
    %set filterseg
    if predictFuture
        filterSeg = segInd;
    else
        filterSeg = segInd + packetSize - 1;
    end
    
    %get net evidence possibilities
    currSegNetEv = netEvidence(:,segInd + packetSize - 1);
    uniqueNetEv = unique(currSegNetEv);
    
    %loop through each net evidence combination
    for netEvInd = 1:length(uniqueNetEv)
        
        %get subset of data
        trialInd = currSegNetEv == uniqueNetEv(netEvInd);
        dataSub = dataCell(trialInd);
        tempPacketSub = packetPatternSub(trialInd,:);
        
        %if only one packet type, skip
        if all(ismember(leftPackets,unique(tempPacketSub,'rows'),'rows'))
            
            %get left trial subset
            tempTrialSubLeft = getMatchedTrials(tempPacketSub,leftPackets,...
                netEvidence,dataSub,segInd);
            
            %get distances
            [tempIntraLeft,tempInterLeft] = getSubDistances(tempTrialSubLeft,...
                1:packetSize-1,filterSeg,whichFactor,predictFuture,traceType);
            
            %store
            intraLeft = cellfun(@(x,y) cat(1,x,y),intraLeft,tempIntraLeft,...
                'UniformOutput',false);
            interLeft = cellfun(@(x,y) cat(1,x,y),interLeft,tempInterLeft,...
                'UniformOutput',false);
        end
        
        if all(ismember(rightPackets,unique(tempPacketSub,'rows'),'rows'))
            
            %get right trial subset
            tempTrialSubRight = getMatchedTrials(tempPacketSub,rightPackets,...
                netEvidence,dataSub,segInd);
            
            %get distances
            [tempIntraRight,tempInterRight] = getSubDistances(tempTrialSubRight,...
                1:packetSize-1,filterSeg,whichFactor,predictFuture,traceType);
            
            %store
            intraRight = cellfun(@(x,y) cat(1,x,y),intraRight,tempIntraRight,...
                'UniformOutput',false);
            interRight = cellfun(@(x,y) cat(1,x,y),interRight,tempInterRight,...
                'UniformOutput',false);
        end
        
    end
end

%combine right and left
intraAll = cellfun(@(x,y) cat(1,x,y),intraRight,intraLeft,...
    'UniformOutput',false);
interAll = cellfun(@(x,y) cat(1,x,y),interRight,interLeft,...
    'UniformOutput',false);

%output
if separateLeftRight
    varargout{1} = intraLeft;
    varargout{2} = intraRight;
    varargout{3} = interLeft;
    varargout{4} = interRight;
else
    varargout{1} = intraAll;
    varargout{2} = interAll;
    
    %plot
    if shouldPlot
        plotPooledDistances(separateLeftRight,1,varargout);
    end
    
end


end

function [intraDist,interDist] = getSubDistances(trialSub,whichSeg,...
    segInd,whichFactor,predictFuture,traceType)
%get segTraces
[segTraces, segId, ~, segNum] = extractSegmentTraces(trialSub,...
    'outputTrials',true,'tracetype',traceType,'whichFactor',whichFactor); %extracts mean response during each segment

%filter segNum
shouldKeepSegNumVector = ismember(segNum,segInd);
shouldKeepSegNum = permute(repmat(shouldKeepSegNumVector,1,1,size(segTraces,1)),[3 2 1]);
segTraces(~shouldKeepSegNum) = NaN;

%convert which seg to seg numbers
if predictFuture
    segToPredict = segInd + whichSeg;
else
    segToPredict = segInd - whichSeg;
end

%get response (nTrials x nNeurons)
segResponse = squeeze(segTraces(:,segInd,:))';

%calculate distances
distances = squareform(pdist(segResponse));

%zero distances above the diagonal
distances = tril(distances);


%initialize
interDist = cell(size(segToPredict));
intraDist = cell(size(interDist));

%subset distances into intra and inter
for currPredict = segToPredict
    
    %get trial labels (nTrials x 1)
    labels = segId(:,currPredict);
    
    %create match matrix
    isMatch = bsxfun(@eq,labels,labels');
    
    %get intra/inter distances
    tempIntraDist = distances(isMatch);
    tempInterDist = distances(~isMatch);
    
    %remove 0 values
    tempIntraDist(tempIntraDist==0) = [];
    tempInterDist(tempInterDist==0) = [];
    
    %store
    interDist{segInd-currPredict} = tempInterDist;
    intraDist{segInd-currPredict} = tempIntraDist;
    
end

end

function [trialSub] = getMatchedTrials(packetPatternSub,matchPackets,...
    netEvidence,dataCell,segInd)

%find all trials which match left triplet
tripletMatch = ismember(packetPatternSub,matchPackets,'rows');

%take subsets
netEvSub = netEvidence(tripletMatch,:);
trialSub = dataCell(tripletMatch);

%match trials with equal net evidence
if segInd > 1 %if past first segment
    
    %find unique net evidence at segment before current segment
    [uniqueNetEv, nUniqueNetEv] = count_unique(netEvSub(:,segInd-1));
    
    %find the maximum number of trials attainable
    [sortNNetEv,sortInd] = sort(nUniqueNetEv,'descend');
    uniqueNetEv = uniqueNetEv(sortInd);
    maxPossible = sortNNetEv'.*[1:length(uniqueNetEv)];
    [~,maxInd] = max(maxPossible);
    
    %initialize trial group (final set of trials with equal numbers
    %of all net evidence conditions prior to packet start)
    trialGroup = nan(sortNNetEv(maxInd),maxInd);
    
    %pick number matching minimum of each of the other net evidence
    %conditions and add to group
    for netEvInd = 1:maxInd
        
        %find trial indices which match net evidence
        netEvMatchTrials = find(netEvSub(:,segInd-1)==uniqueNetEv(netEvInd));
        
        %pick random trials
        %         trialGroup(:,netEvInd) = randsample(netEvMatchTrials,sortNNetEv(maxInd));
        
        %take first set of trials which match
        trialGroup(:,netEvInd) = netEvMatchTrials(1:sortNNetEv(maxInd));
    end
    
    %reshape trial group
    trialGroup = trialGroup(:);
    
    %create final, matched subset
    trialSub = trialSub(trialGroup);
end

end
