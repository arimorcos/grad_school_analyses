function [SVMPerf, SVMShuffle, SVMPredict, SVMProbEst, SVMShuffleEst] =...
    predictPrevSegIdSVM(dataCell,varargin)
%predictPrevSegIdSVM.m Uses a binary svm to predict the current and past
%segment ids
%
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OPTIONAL INPUTS
%nKFold - number of cross-validation folds
%shouldStandardize - shouldStandardize data
%filterTrials - string to filter trials
%shouldShuffle - should shuffle or not
%nShuffles - number of shuffles
%trialLimit - limit number of trials to pull from. Should be a scalar > 1 
%filterNetEv - limit to a specific amount of net evidence
%filterSegID - limit to a specific segment identity. Must be -1 or 1.
%filterTurn - limit to a specific turn direction. Must be 0 or 1
%filterSegNum - limit to a specific segment number
%cParam - parameter for amount of regularization
%gamma - for RBF kernel, controls spread of gaussian. Default is
%   1/nFeatures
%kernel - kernel type. Default is 'rbf'
%svmType - svm type. Options are 'SVC,' 'e-SVR,' 'nu-SVR'
%epsilon - epsilon for epsilon SVR
%nu - nu for nu-SVR
%kFold - number of cross validations. Default is 10;
%whichSeg - which segment to predict. Default is 0:5. 0 implies current
%   segment, 1 - 1 segment back, etc.
%segHistResponse - 1 x nSeg cell containing nTrials x nNeurons responses
%   for 0 seg back, 1 seg back, etc. Overwrites first part of function
%segHistId - 1 x nSeg cell containing nTrials x 1 trial ids
%   for 0 seg back, 1 seg back, etc. Overwrites first part of function
%predictFuture - predict future or past segments. Default is false
%
%OUTPUTS
%SVMPerf - 1 x nSeg array containing fraction correct of classification by
%   SVM for current segment, 1 segment back ,2 seg back, etc. 
%SVMSHuffle - nShuffle x nSeg array containing shuffled svm performance
%SVMPRedict - 1 x nSeg cell array of SVM label predictions
%
%
%ASM 12/14

params.cParam = 1;
params.gamma = 1/300;
params.kernel = 'rbf';
params.svmType = 'SVC';
params.nu = 0.5;
params.epsilon = 0.1;
params.kFold = 10;
params.leaveOneOut = false;
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
predictFuture = false;
traceType = 'dfffactor';
whichFactorSet = 1;
whichFactors = 1:5;

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
            case 'whichseg'
                whichSeg = varargin{argInd+1};
            case 'seghistid'
                segHistId = varargin{argInd+1};
            case 'seghistresponse'
                segHistResponse = varargin{argInd+1};
            case 'predictfuture'
                predictFuture = varargin{argInd+1};
            case 'leaveoneout'
                params.leaveOneOut = varargin{argInd+1};
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
        'outputTrials',true,'traceType',traceType,'whichFactor',whichFactorSet); %extracts mean response during each segment 
    
    %subset if factor analysis
    if strcmpi(traceType,'dfffactor')
        segTraces = segTraces(whichFactors,:,:);
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

%calculate svms 
[SVMPerf, SVMPredict, SVMProbEst] = trainSegIDSVM(segHistId,segHistResponse,params,0);

%shuffle if necessary
if shouldShuffle
    
    %initialize
    nSeg = length(segHistId);
    SVMShuffle = nan(nShuffles,nSeg);
    SVMShuffleEst = cell(nShuffles,nSeg);
    
    parfor shuffleInd = 1:nShuffles
        
        %shuffle labels 
        tempId = cell(1,nSeg);
        tempId(~cellfun(@isempty,segHistId)) = ...
            cellfun(@(x) randsample(x,numel(x)),...
            segHistId(~cellfun(@isempty,segHistId)),'UniformOutput',false);
        
        %train svms
        [SVMShuffle(shuffleInd,:),~,SVMShuffleEst(shuffleInd,:)] =...
            trainSegIDSVM(tempId,segHistResponse,params,shuffleInd);
    end
else
    SVMShuffle = [];
    SVMShuffleEst = [];
end

end

function [SVMPerf, SVMPredict, SVMProbEst] = trainSegIDSVM(segHistId,segHistResponse,params,shuffleNum)

%train support vector machine on trainFrac of the data
nSeg = length(segHistId);
SVMPredict = cell(1,nSeg);
SVMPerf = nan(1,nSeg);
SVMProbEst = cell(1,nSeg);
for segPredict = 1:nSeg
    dispProgress('Creating shuffle %d svm %d/%d',segPredict,shuffleNum,segPredict,nSeg);
    
    %skip if empty 
    if isempty(segHistResponse{segPredict})
        continue;
    end
    
    %get svm accuracy
    [SVMPerf(segPredict), SVMPredict{segPredict}, ~, SVMProbEst{segPredict}] = getSVMAccuracy( ...
        segHistResponse{segPredict}, segHistId{segPredict}, 'c', params.cParam,...
        'gamma', params.gamma, 'kernel', params.kernel, 'svmType', params.svmType,...
        'epsilon', params.epsilon, 'nu', params.nu, 'kFold', params.kFold,...
        'leaveOneOut',params.leaveOneOut);
end
end