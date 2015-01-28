function [info, shuffleInfo] = calcMutInfoSegmentIdentity(dataCell,varargin)
%calcMutInfoSegmentIdentity.m Calculates the mutual information between the
%current neuronal response and the segment identity of each
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
%singleNeuron - limit to a single neuron. If not empty, provide scalar
%   neuron num
%method - mutual information calculation method. 'dr' or 'gs'. Default is
%   'dr'
%bias - bias correction method.
%btsp - number of shuffles
%nBins - number of neuronal bins
%xtrp - number of extrapolations for qe bias correction
%binFunc - binning function
%matchTrials - match the same number of samples for each comparison
%
%OUTPUTS
%info - 1 x nSeg array of mutual information
%shuffleInfo - nShuffles x nSeg array of shuffled mutual information
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
singleNeuron = [];
params.method = 'dr';
params.bias = 'naive';
params.btsp = 0;
params.nBins = 3;
params.xtrp = 3;
params.binFunc = 'eqspace';
matchTrials = false;
singleNeuronBinRange = [0.5 0.75];

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
            case 'singleneuron'
                singleNeuron = varargin{argInd+1};
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
            case 'matchtrials'
                matchTrials = varargin{argInd+1};
            case 'singleneuronbinrange'
                singleNeuronBinRange = varargin{argInd+1};
        end
    end
end

%filter trials
dataCell = getTrials(dataCell,filterTrials);

%limit trials
if ~isempty(trialLimit) && length(dataCell) > trialLimit
    toKeepTrialLimit = randperm(length(dataCell),trialLimit);
    dataCell = dataCell(toKeepTrialLimit);
end

%get segTraces
if isempty(singleNeuron)
    [segTraces, segId, netEv, segNum, ~, ~, ~, turn] = extractSegmentTraces(dataCell,...
        'outputTrials',true,'traceType','dffFactor','whichFactor',2); %extracts mean response during each segment
else
    [segTraces, segId, netEv, segNum, ~, ~, ~, turn] = extractSegmentTraces(dataCell,...
        'outputTrials',true,'traceType','dff','useBins','true'); %extracts mean response during each segment
    segTraces = squeeze(segTraces(singleNeuron,:,:,:));
    binRange = round(singleNeuronBinRange*size(segTraces,1));
    segTraces = segTraces(binRange(1):binRange(2),:,:);
    
end


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
    
    %get response
    segHistResponse{segPredict} = reshape(segTraces(:,segPredict:nSeg,:),...
        nNeurons,(nSeg+1-segPredict)*nTrials);
    
    %get other variables
    segHistId{segPredict} = reshape(segId(:,1:(nSeg-segPredict+1))',nTrials*(nSeg+1-segPredict),1);
    
    %remove nans
    toRemoveResponse = isnan(segHistResponse{segPredict});
    toRemoveId = any(toRemoveResponse,2);
    segHistId{segPredict}(toRemoveId) = [];
    segHistResponse{segPredict}(toRemoveId,:) = [];
    
end

%match trials if necessary
if matchTrials
    trialLengths = cellfun(@length,segHistId);
    minTrials = min(trialLengths);
    for currSeg = 1:nSeg
        %generate random indices
        randInd = randsample(trialLengths(currSeg),minTrials);
        segHistId{currSeg} = segHistId{currSeg}(randInd);
        segHistResponse{currSeg} = segHistResponse{currSeg}(:,randInd);
    end
end

%calculate mutual information
shuffleNum = 0;
info = getMutualInfo(segHistId,segHistResponse,nSeg,params,shuffleNum);

%shuffle if necessary
if shouldShuffle
    
    %initialize
    shuffleInfo = nan(nShuffles,nSeg);
    
    parfor shuffleInd = 1:nShuffles
        
        %shuffle labels
        tempId = cellfun(@(x) randsample(x,numel(x)),segHistId,'UniformOutput',false);
        
        %train svms
        shuffleInfo(shuffleInd,:) = getMutualInfo(tempId,segHistResponse,nSeg,params,shuffleNum);
    end
else
    shuffleInfo = [];
end

end

function info = getMutualInfo(segHistId,segHistResponse,nSeg,params,shuffleNum)

%train support vector machine on trainFrac of the data
info = nan(1,nSeg);

for segPredict = 1:nSeg
    dispProgress('Getting mutual info shuffle %d seg %d/%d',segPredict,shuffleNum,segPredict,nSeg);
    
    %skip if empty
    if isempty(segHistResponse{segPredict})
        continue;
    end
    
    %get info
    info(segPredict) = calcCorrectedMutualInfo(segHistResponse{segPredict},segHistId{segPredict},...
        'method', params.method, 'bias', params.bias, 'btsp', params.btsp,...
        'xtrp', params.xtrp, 'binFunc', params.binFunc, 'nbins', params.nBins);
end
end