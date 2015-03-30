function classifierOut = classifyNetEvIndSegSVM(dataCell,varargin)
%classifyNetEvIndSeg.m Classifies which net evidence condition a given bin
%of each segment is. Classifies individual segments separately.
%
%INPUTS
%dataCell - dataCell containing imaging information
%shouldPlot - should plot data
%
%OUTPUTS
%accuracy - nSeg x nBins array containing accuracy for each bin of each
%   segment
%classGuess - nTrials x nBins x nSeg array of classifier guesses
%realClass - nTrials x nSeg array of actual net evidence
%
%ASM 9/14

nShuffles = 100;
shouldShuffle = false;
traceType = 'dff';
whichFactor = 2;
range = [0.5 0.75];
conditions = {'','result.leftTurn==1','result.leftTurn==0'};
trainFrac = 0.5;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'nshuffles'
                nShuffles = varargin{argInd+1};
            case 'shouldshuffle'
                shouldShuffle = varargin{argInd+1};
            case 'tracetype'
                traceType = varargin{argInd+1};
            case 'whichfactor'
                whichFactor = varargin{argInd+1};
            case 'usemode'
                useMode = varargin{argInd+1};
            case 'range'
                range = varargin{argInd+1};
            case 'conditions'
                conditions = varargin{argInd+1};
        end
    end
end

%loop through each condition
for condInd = 1:length(conditions)
    
    %filter subset
    dataSub = getTrials(dataCell,conditions{condInd});
    
    %get nTrials
    nTrials = length(dataSub);
    
    %get segTraces
    [segTraces,~,netEv,segNum,~,~] = extractSegmentTraces(dataSub,'usebins',true,...
        'tracetype',traceType,'whichFactor',whichFactor);
    
    %take mean
    meanBinRange = round(range*size(segTraces,2));
    segTraces = mean(segTraces(:,meanBinRange(1):meanBinRange(2),:),2);
    
    %get nSeg
    nSeg = max(segNum);
    
    %get nBins
    nBins = size(segTraces,2);
    
    %get nTest
    nTest = round(nTrials*(1-trainFrac));
    
    %reshape netEv
    realClass = reshape(netEv,nTrials,nSeg);
    
    %calculate actual accuracy
    [guess, testClass, mse, corrCoef] = getNetEvIndSegData(segTraces,nSeg,...
        realClass,nBins,nTrials,nTest,trainFrac);    
    
    %shuffle
    if shouldShuffle
        %initialize
        shuffleMSE = nan(nSeg,1,nShuffles);
        shuffleGuess = nan(nTest,nSeg,nShuffles);
        shuffleTestClass = nan(nTest,nSeg,nShuffles);
        shuffleCorrCoef = nan(size(shuffleMSE));
        
        for shuffleInd = 1:nShuffles
            dispProgress('Performing shuffle %d/%d',shuffleInd,shuffleInd,nShuffles);
            %generate random netEv conditions
            randClass = nan(size(realClass));
            for segInd = 1:nSeg
                randClass(:,segInd) = shuffleArray(realClass(:,segInd));
            end
            
            [shuffleGuess(:,:,shuffleInd), shuffleTestClass(:,:,shuffleInd),...
                shuffleMSE(:,:,shuffleInd),shuffleCorrCoef(:,:,shuffleInd)] =...
                getNetEvIndSegData(segTraces,nSeg,randClass,nBins,nTrials,...
                nTest,trainFrac);
        end
    else
        shuffleMSE = [];
        shuffleCorrCoef = [];
        shuffleGuess = [];
        shuffleTestClass = [];
    end
    
    %save to classifier out
    classifierOut(condInd).shuffleMSE = shuffleMSE;
    classifierOut(condInd).shuffleCorrCoef = shuffleCorrCoef;
    classifierOut(condInd).shuffleGuess = shuffleGuess;
    classifierOut(condInd).shuffleTestClass = shuffleTestClass;
    classifierOut(condInd).corrCoef = corrCoef;
    classifierOut(condInd).mse = mse;    
    classifierOut(condInd).testClass = testClass;    
    classifierOut(condInd).guess = guess;    
end

function [guess, testClass, mse, corrCoef] = getNetEvIndSegData(segTraces,nSeg,...
    realClass,nBins,nTrials,nTest, trainFrac)

%initialize outputs
mse = nan(nSeg,nBins);
corrCoef = nan(size(mse));
guess = nan(nTest,nSeg);
testClass = nan(nTest,nSeg);

%loop through each segment and get accuracy
for segInd = 1:nSeg
    %get trace indices
    trialInd = nTrials*(segInd-1)+1:nTrials*segInd;
    
    %calculate accuracy
    [guess(:,segInd),mse(segInd,:),testClass(:,segInd),corrCoef(segInd,:)] =...
        getSVMAccuracy(segTraces(:,:,trialInd),realClass(:,segInd),...
        'svmType', 'e-SVR', 'C',50,'epsilon',0.004,'gamma',0.04,'kFold',1,...
        'trainFrac',trainFrac);
end

