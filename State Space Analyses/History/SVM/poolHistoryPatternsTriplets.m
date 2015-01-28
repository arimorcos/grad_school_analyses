function [varargout] = poolHistoryPatternsTriplets(dataCell,varargin)
%poolHistoryPatterns.m Pools different net evidence condition history
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
packetSize = 3;
nShuffles = 100;
trialMin = 10;
poolAllSeg = true;
separateLeftRight = false;
mode = 'svm';
whichFactor = 1;
predictFuture = false;
params.cParam = 30000;
params.gamma = 0.145;
params.kernel = 'rbf';
params.svmType = 'SVC';
params.nu = 0.5;
params.epsilon = 0.1;
params.kFold = 0;
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
            case 'trialmin'
                trialMin = varargin{argInd+1};
            case 'poolallseg'
                poolAllSeg = varargin{argInd+1};
            case 'separateleftright'
                separateLeftRight = varargin{argInd+1};
            case 'mode'
                mode = varargin{argInd+1};
            case 'whichfactor'
                whichFactor = varargin{argInd+1};
            case 'predictfuture'
                predictFuture = varargin{argInd+1};
            case 'c'
                params.cParam = varargin{argInd+1};
            case 'gamma'
                params.gamma = varargin{argInd+1};
            case 'kernel'
                params.kernel = varargin{argInd+1};
            case 'svmtype'
                params.svmType = varargin{argInd+1};
            case 'nu'
                params.nu = varargin{argInd+1};
            case 'epsilon'
                params.epsilon = varargin{argInd+1};
            case 'kfold'
                params.kFold = varargin{argInd+1};
            case 'tracetype'
                traceType = varargin{argInd+1};
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
packetComb(sum(packetComb,2) == 0 | sum(packetComb,2) == packetSize,:) = []; %delete packets with all the same values
leftPackets = packetComb([3 5],:);
rightPackets = packetComb([2 4],:);
nPackets = 2;

%flip packets if future
if predictFuture
    leftPackets = fliplr(leftPackets);
    rightPackets = fliplr(rightPackets);
end

%determine how many packet/seg combinations there are
totalComb = nPackets*(nSeg-2);

%initialize
if poolAllSeg
    segHistIdLeft = cell(1,nSeg);
    segHistIdRight = cell(1,nSeg);
    segHistResponseLeft = cell(1,nSeg);
    segHistResponseRight = cell(1,nSeg);
else
    resultLeft = nan(totalComb,packetSize);
    resultRight = nan(size(resultLeft));
    resultShuffleLeft = nan(totalComb,nShuffles,packetSize);
    resultShuffleRight = nan(size(resultShuffleLeft));
end
combInd = 1;


%loop through each packet/segment number combination
for segInd = 1:nSeg-2
    
    %extract portion of maze which is relevant
    packetPatternSub = mazePatterns(:,segInd:segInd+2);
    
    %loop through each triplet
    %     for tripletInd = 1:nPackets
    
    if poolAllSeg
        %set filterseg
        if predictFuture
            filterSeg = segInd;
        else
            filterSeg = segInd+2;
        end
        
        %get left svm perf
        [~,~,tempTrialSubLeft] = ...
            getSVMPacketPerf(packetPatternSub,leftPackets,...
            netEvidence,dataCell,nShuffles,segInd,packetSize,trialMin,false,mode);
        [tempSegHistIdLeft,tempSegHistResponseLeft] = constructSegSubsets(tempTrialSubLeft,...
            0:packetSize-1,filterSeg,mode,whichFactor,predictFuture,traceType);
        segHistIdLeft = cellfun(@(x,y) cat(1,x,y),segHistIdLeft,tempSegHistIdLeft,...
            'UniformOutput',false);
        segHistResponseLeft = cellfun(@(x,y) cat(1,x,y),segHistResponseLeft,tempSegHistResponseLeft,...
            'UniformOutput',false);
        
        
        %get right svm perf
        [~,~,tempTrialSubRight] = ...
            getSVMPacketPerf(packetPatternSub,rightPackets,...
            netEvidence,dataCell,nShuffles,segInd,packetSize,trialMin,false,mode);
        [tempSegHistIdRight,tempSegHistResponseRight] = constructSegSubsets(tempTrialSubRight,...
            0:packetSize-1,filterSeg,mode,whichFactor,predictFuture,traceType);
        segHistIdRight = cellfun(@(x,y) cat(1,x,y),segHistIdRight,tempSegHistIdRight,...
            'UniformOutput',false);
        segHistResponseRight = cellfun(@(x,y) cat(1,x,y),segHistResponseRight,tempSegHistResponseRight,...
            'UniformOutput',false);
        
    else
        %get left svm perf
        [resultLeft(combInd,:), resultShuffleLeft(combInd,:,:)] = ...
            getSVMPacketPerf(packetPatternSub,leftPackets,...
            netEvidence,dataCell,nShuffles,segInd,packetSize,trialMin,true,...
            mode,whichFactor,predictFuture,params);
        
        %get right svm perf
        [resultRight(combInd,:), resultShuffleRight(combInd,:,:)] = ...
            getSVMPacketPerf(packetPatternSub,rightPackets,...
            netEvidence,dataCell,nShuffles,segInd,packetSize,trialMin,true,...
            mode,whichFactor,predictFuture,params);
    end
    
    combInd = combInd + 1;
    %     end
    
end

if poolAllSeg
    switch mode
        case 'svm'
            %run svm
            [resultLeft, resultShuffleLeft] = predictPrevSegIdSVM([],...
                'shouldShuffle',true,'nShuffles',nShuffles,'segHistId',...
                segHistIdLeft,'segHistResponse',segHistResponseLeft,...
                'kFold',params.kFold,'c',params.cParam,'gamma',params.gamma,...
                'kernel',params.kernel,'svmtype',params.svmType,'nu',...
                params.nu,'epsilon',params.epsilon);
            [resultRight, resultShuffleRight] = predictPrevSegIdSVM([],...
                'shouldShuffle',true,'nShuffles',nShuffles,'segHistId',...
                segHistIdRight,'segHistResponse',segHistResponseRight,...
                'kFold',params.kFold,'c',params.cParam,'gamma',params.gamma,...
                'kernel',params.kernel,'svmtype',params.svmType,'nu',...
                params.nu,'epsilon',params.epsilon);
        case 'info'
            %get info
            [resultLeft, resultShuffleLeft] = predictPrevSegIdInfo([],...
                'shouldShuffle',true,'nShuffles',nShuffles,'segHistId',...
                segHistIdLeft,'segHistResponse',segHistResponseLeft,...
                'whichFactor',whichFactor);
            [resultRight, resultShuffleRight] = predictPrevSegIdInfo([],...
                'shouldShuffle',true,'nShuffles',nShuffles,'segHistId',...
                segHistIdRight,'segHistResponse',segHistResponseRight,...
                'whichFactor',whichFactor);
    end
    %crop
    resultShuffleLeft = resultShuffleLeft(:,1:packetSize);
    resultShuffleRight = resultShuffleRight(:,1:packetSize);
end

%combine all shuffle values %%%% CURRENTLY BROKEN
resultShuffleLeft = reshape(resultShuffleLeft,[],packetSize);
resultShuffleRight = reshape(resultShuffleRight,[],packetSize);
resultShuffleAll = cat(1,resultShuffleLeft,resultShuffleRight);

%combine left and right perf
resultAll = cat(1,resultLeft,resultRight);

%set outputs
if separateLeftRight
    varargout{1} = resultLeft;
    varargout{2} = resultRight;
    varargout{3} = resultShuffleLeft;
    varargout{4} = resultShuffleRight;
else
    varargout{1} = resultAll;
    varargout{2} = resultShuffleAll;
end
end

function [segHistId,segHistResponse] = constructSegSubsets(trialSub,whichSeg,...
    segInd,mode,whichFactor,predictFuture,traceType)
%get segTraces
switch mode
    case 'svm'
        [segTraces, segId, ~, segNum] = extractSegmentTraces(trialSub,...
            'outputTrials',true,'tracetype',traceType,'whichFactor',whichFactor); %extracts mean response during each segment
    case 'info'
        [segTraces, segId, ~, segNum] = extractSegmentTraces(trialSub,...
            'outputTrials',true,'tracetype','dfffactor','whichfactor',whichFactor); %extracts mean response during each segment
end

%filter segNum
shouldKeepSegNumVector = ismember(segNum,segInd);
shouldKeepSegNum = permute(repmat(shouldKeepSegNumVector,1,1,size(segTraces,1)),[3 2 1]);
segTraces(~shouldKeepSegNum) = NaN;

%get nTrials, nNeurons, nSeg
[nNeurons, nSeg, nTrials] = size(segTraces);

%bin into groups based on many segments back can compute
segHistResponse = cell(1,nSeg);
segHistId = cell(1,nSeg);
for segPredict = 1:nSeg %which segment to predict. If 0, current, if 1, 1 back, etc.
    
    if ~ismember(segPredict,whichSeg+1)
        continue;
    end
    
    if predictFuture
        
        %get response
        segHistResponse{segPredict} = reshape(segTraces(:,1:(nSeg-segPredict+1),:),...
            nNeurons,(nSeg+1-segPredict)*nTrials)';
        
        %get other variables
        segHistId{segPredict} = reshape(segId(:,segPredict:nSeg)',nTrials*(nSeg+1-segPredict),1);
        
    else
        
        %get response
        segHistResponse{segPredict} = reshape(segTraces(:,segPredict:nSeg,:),...
            nNeurons,(nSeg+1-segPredict)*nTrials)';
        
        %get other variables
        segHistId{segPredict} = reshape(segId(:,1:(nSeg-segPredict+1))',nTrials*(nSeg+1-segPredict),1);
        
    end
    
    %remove nans
    toRemoveResponse = isnan(segHistResponse{segPredict});
    toRemoveId = any(toRemoveResponse,2);
    segHistId{segPredict}(toRemoveId) = [];
    segHistResponse{segPredict}(toRemoveId,:) = [];
    
end
end

function [result, resultShuffle, trialSub] = getSVMPacketPerf(packetPatternSub,matchPackets,...
    netEvidence,dataCell,nShuffles,segInd,packetSize,trialMin,runClassifier,mode,whichFactor,...
    predictFuture,params)

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

%ignore if less than trial min
if length(trialSub) < trialMin || ~runClassifier
    result = nan(1,packetSize);
    resultShuffle = nan(nShuffles,packetSize);
    return;
end

%set filterSeg
if predictFuture
    filterSeg = segInd;
else
    filterSeg = segInd+2;
end

%get svm result
switch mode
    case 'svm'
        [result, resultShuffle] = predictPrevSegIdSVM(trialSub,'whichSeg',0:packetSize-1,...
            'shouldShuffle',true,'nShuffles',nShuffles,'filterSegNum',filterSeg,...
            'predictFuture',predictFuture,...
            'kFold',params.kFold,'c',params.cParam,'gamma',params.gamma,...
            'kernel',params.kernel,'svmtype',params.svmType,'nu',...
            params.nu,'epsilon',params.epsilon);
    case 'info'
        [result, resultShuffle] = predictPrevSegIdInfo(trialSub,'whichSeg',0:packetSize-1,...
            'shouldShuffle',true,'nShuffles',nShuffles,'filterSegNum',filterSeg,...
            'whichFactor',whichFactor);
end

%crop
result = result(1:packetSize);
resultShuffle = resultShuffle(:,1:packetSize);

end