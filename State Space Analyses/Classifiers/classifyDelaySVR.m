function classifierOut = classifyDelaySVR(dataCell,varargin)
%classifyDelaySVR.m Classifies which net evidence condition a given bin
%of each segment is. Classifies during the delay period.
%
%INPUTS
%dataCell - dataCell containing imaging information
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
range = [0 0.25];
conditions = {'','result.leftTurn==1','result.leftTurn==0'};
trainFrac = 0.5;
classMode = 'netEv';
binViewAngle = false;
leftViewAngle = true;
viewAngleRange = 5;

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
            case 'classmode'
                classMode = varargin{argInd+1};
            case 'range'
                range = varargin{argInd+1};
            case 'conditions'
                conditions = varargin{argInd+1};
            case 'binviewangle'
                binViewAngle = varargin{argInd+1};
            case 'leftviewangle'
                leftViewAngle = varargin{argInd+1};
            case 'viewanglerange'
                viewAngleRange = varargin{argInd+1};
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
    [~,~,netEv,segNum,numLeft,~,delayTraces,~,~,whichBins] = extractSegmentTraces(dataSub,'usebins',true,...
        'tracetype',traceType,'whichFactor',whichFactor,'getDelay',true);
    
    %crop outputs
    netEv = netEv(end-nTrials+1:end);
    segNum = segNum(end-nTrials+1:end);
    numLeft = numLeft(end-nTrials+1:end);
    delayBins = whichBins{end};
    
    %get nSeg
    nSeg = max(segNum);
    
    %take mean
    meanBinRange = max(1,round(range*size(delayTraces,2)));
    delayTraces = mean(delayTraces(:,meanBinRange(1):meanBinRange(2),:),2);
    delayBins = delayBins(meanBinRange(1):meanBinRange(2));
    
    %get view angle
    if binViewAngle
        %get binned dataframes
        binnedDF = catBinnedDataFrames(dataSub);
        
        %crop to view angle and delayBins and convert to degrees nTrials x
        %1
        viewAngle = rad2deg(squeeze(mean(binnedDF(4,delayBins,:),2)));
        
        %take overall mean
        meanViewAngle = mean(viewAngle);
        
        if strcmpi(conditions{condInd},'')
            %get mean of section to use
            if leftViewAngle
                meanSection = mean(viewAngle(viewAngle >= meanViewAngle));
            else
                meanSection = mean(viewAngle(viewAngle < meanViewAngle));
            end
        else
            meanSection = meanViewAngle;
        end
        
        %take indices of all trials within range of section mean
        keepInd = viewAngle >= (meanSection - viewAngleRange) &...
            viewAngle <= (meanSection + viewAngleRange);
        
        %filter everything based on keepInd
        delayTraces = delayTraces(:,:,keepInd);
        netEv = netEv(keepInd);
        segNum = segNum(keepInd);
        numLeft = numLeft(keepInd);
        nTrials = sum(keepInd);
    end
    
    %get nTest
    nTest = floor(nTrials*(1-trainFrac));
    
    %get realClass
    switch lower(classMode)
        case 'netev'
            realClass = netEv;
        case 'numleft'
            realClass = numLeft;
        case 'numright'
            realClass = nSeg - numLeft;
        otherwise
            error('Can''t interpret class mode');
    end
    
    %calculate actual accuracy
    [guess, testClass, mse, corrCoef] = getNetEvGroupSegData(delayTraces,...
        realClass, trainFrac);
    
    %shuffle
    if shouldShuffle
        %initialize
        shuffleMSE = nan(nShuffles,1);
        shuffleGuess = nan(nTest,nShuffles);
        shuffleTestClass = nan(nTest,nShuffles);
        shuffleCorrCoef = nan(size(shuffleMSE));
        
        for shuffleInd = 1:nShuffles
            dispProgress('Performing shuffle %d/%d',shuffleInd,shuffleInd,nShuffles);
            %generate random netEv conditions
            randClass = shuffleArray(realClass);
            
            [shuffleGuess(:,shuffleInd), shuffleTestClass(:,shuffleInd),...
                shuffleMSE(shuffleInd),shuffleCorrCoef(shuffleInd)] =...
                getNetEvGroupSegData(delayTraces,randClass,trainFrac);
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
    classifierOut(condInd).classMode = classMode;
end

function [guess, testClass, mse, corrCoef] = getNetEvGroupSegData(segTraces,...
    realClass, trainFrac)

%calculate accuracy
[guess,mse,testClass,corrCoef] =...
    getSVMAccuracy(segTraces,realClass,...
    'svmType', 'e-SVR', 'C',50,'epsilon',0.004,'gamma',0.04,'kFold',1,...
    'trainFrac',trainFrac);

