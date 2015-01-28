function [info, infoShuffle] = predictPrevSegIdInfo(dataCell,varargin)
%predictPrevSegIdInfo.m Uses mutual information to predict the current and past
%segment ids
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OPTIONAL INPUTS
%filterTrials - string to filter trials
%shouldShuffle - should shuffle or not
%nShuffles - number of shuffles
%trialLimit - limit number of trials to pull from. Should be a scalar > 1 
%filterNetEv - limit to a specific amount of net evidence
%filterSegID - limit to a specific segment identity. Must be -1 or 1.
%filterTurn - limit to a specific turn direction. Must be 0 or 1
%filterSegNum - limit to a specific segment number
%whichSeg - which segment to predict. Default is 0:5. 0 implies current
%   segment, 1 - 1 segment back, etc.
%segHistResponse - 1 x nSeg cell containing nTrials x nNeurons responses
%   for 0 seg back, 1 seg back, etc. Overwrites first part of function
%segHistId - 1 x nSeg cell containing nTrials x 1 trial ids
%   for 0 seg back, 1 seg back, etc. Overwrites first part of function
%method - mutual information calculation method. 'dr' or 'gs'. Default is
%   'dr'
%bias - bias correction method. 
%btsp - number of shuffles
%nBins - number of neuronal bins
%xtrp - number of extrapolations for qe bias correction
%binFunc - binning function
%whichFactor - which factor analysis to use
%
%OUTPUTS
%info - 1 x nSeg array containing information in bits for current segment,
%    1 segment back ,2 seg back, etc. 
%infoShuffle - nShuffle x nSeg array containing shuffled info
%
%ASM 12/14

filterTrials = '';
shouldShuffle = false;
nShuffles = 100;
trialLimit = [];
filterNetEv = [];
filterSegNum = [];
filterTurn = [];
filterSegID = [];
whichSeg = 0:5;
segHistResponse = [];
segHistId = [];
params.method = 'dr';
params.bias = 'pt';
params.btsp = 100;
params.nBins = 100;
params.xtrp = 1;
params.binFunc = 'eqspace';
whichFactor = 1;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'filtertrials'
                filterTrials = varargin{argInd+1};
            case 'shouldshuffle'
                shouldShuffle = varargin{argInd+1};
            case 'nshuffles'
                nShuffles = varargin{argInd+1};
            case 'triallimit'
                trialLimit = varargin{argInd+1};
            case 'filternetev'
                filterNetEv = varargin{argInd+1};
            case 'filtersegnum'
                filterSegNum = varargin{argInd+1};
            case 'filterturn'
                filterTurn = varargin{argInd+1};
            case 'filtersegid'
                filterSegID = varargin{argInd+1};
            case 'whichseg'
                whichSeg = varargin{argInd+1};
            case 'seghistid'
                segHistId = varargin{argInd+1};
            case 'seghistresponse'
                segHistResponse = varargin{argInd+1};
            case 'nbins'
                params.nBins = varargin{argInd+1};
            case 'bias'
                params.bias = varargin{argInd+1};
            case 'method'
                params.method = varargin{argInd+1};
            case 'btsp'
                params.btsp = varargin{argInd+1};
            case 'xtrp'
                params.xtrp = varargin{argInd+1};
            case 'binfunc'
                params.binFunc = varargin{argInd+1};
            case 'whichfactor'
                whichFactor = varargin{argInd+1};
        end
    end
end

if isempty(segHistId) && isempty(segHistResponse)
    %filter trials
    dataCell = getTrials(dataCell,filterTrials);

    %limit trials 
    if ~isempty(trialLimit) && length(dataCell) > trialLimit
        toKeepTrialLimit = randperm(length(dataCell),trialLimit);
        dataCell = dataCell(toKeepTrialLimit);
    end

    %get segTraces
    [segTraces, segId, netEv, segNum, ~, ~, ~, turn] = extractSegmentTraces(dataCell,...
        'outputTrials',true,'tracetype','dfffactor','whichFactor',whichFactor); %extracts mean response during each segment 

    %filter net evidence if should
    if ~isempty(filterNetEv)
        shouldKeepNetEvVector = ismember(netEv,filterNetEv);
        shouldKeepNetEv = permute(repmat(shouldKeepNetEvVector,1,1,size(segTraces,1)),[3 2 1]);
        segTraces(~shouldKeepNetEv) = NaN;
    end

    %filter segID 
    if ~isempty(filterSegID)
        shouldKeepSegIDVector = ismember(segId,filterSegID);
        shouldKeepSegID = permute(repmat(shouldKeepSegIDVector,1,1,size(segTraces,1)),[3 2 1]);
        segTraces(~shouldKeepSegID) = NaN;
    end

    %filter turn 
    if ~isempty(filterTurn)
        shouldKeepTurnVector = ismember(turn,filterTurn);
        shouldKeepTurn = permute(repmat(shouldKeepTurnVector,1,1,size(segTraces,1)),[3 2 1]);
        segTraces(~shouldKeepTurn) = NaN;
    end

    %filter segNum 
    if ~isempty(filterSegNum)
        shouldKeepSegNumVector = ismember(segNum,filterSegNum);
        shouldKeepSegNum = permute(repmat(shouldKeepSegNumVector,1,1,size(segTraces,1)),[3 2 1]);
        segTraces(~shouldKeepSegNum) = NaN;
    end

    %get nTrials, nNeurons, nSeg
    [nNeurons, nSeg, nTrials] = size(segTraces);

    %bin into groups based on many segments back can compute 
    segHistResponse = cell(1,nSeg);
    segHistId = cell(1,nSeg);
    for segPredict = 1:nSeg %which segment to predict. If 0, current, if 1, 1 back, etc.

        if ~ismember(segPredict,whichSeg+1)
            continue;
        end

        %get response
        segHistResponse{segPredict} = reshape(segTraces(:,segPredict:nSeg,:),...
            nNeurons,(nSeg+1-segPredict)*nTrials)';

        %get other variables
        segHistId{segPredict} = reshape(segId(:,1:(nSeg-segPredict+1))',nTrials*(nSeg+1-segPredict),1);

        %remove nans 
        toRemoveResponse = isnan(segHistResponse{segPredict});
        toRemoveId = any(toRemoveResponse,2);
        segHistId{segPredict}(toRemoveId) = [];
        segHistResponse{segPredict}(toRemoveId,:) = [];

    end
end

%calculate svms 
info = trainSegIDInfo(segHistId,segHistResponse,params,0);

%shuffle if necessary
if shouldShuffle
    
    %initialize
    nSeg = length(segHistId);
    infoShuffle = nan(nShuffles,nSeg);
    
    parfor shuffleInd = 1:nShuffles
        
        %shuffle labels 
        tempId = cell(1,nSeg);
        tempId(~cellfun(@isempty,segHistId)) = ...
            cellfun(@(x) randsample(x,numel(x)),...
            segHistId(~cellfun(@isempty,segHistId)),'UniformOutput',false);
        
        %train svms
        infoShuffle(shuffleInd,:) = trainSegIDInfo(tempId,segHistResponse,params,shuffleInd);
    end
else
    infoShuffle = [];
end

end

function info = trainSegIDInfo(segHistId,segHistResponse,params,shuffleNum)

%train support vector machine on trainFrac of the data
nSeg = length(segHistId);
info = nan(1,nSeg);
for segPredict = 1:nSeg
    dispProgress('Creating shuffle %d info %d/%d',segPredict,shuffleNum,segPredict,nSeg);
    
    %skip if empty 
    if isempty(segHistResponse{segPredict})
        continue;
    end
    
    %get svm accuracy
    info(segPredict) = calcCorrectedMutualInfo( ...
        segHistResponse{segPredict}, segHistId{segPredict}, 'method', params.method,...
        'bias', params.bias, 'nBins', params.nBins, 'btsp', params.btsp,...
        'xtrp', params.xtrp, 'binFunc', params.binFunc);
end
end