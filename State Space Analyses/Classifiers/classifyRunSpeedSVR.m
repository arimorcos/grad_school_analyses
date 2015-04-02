function classifierOut = classifyRunSpeedSVR(dataCell,varargin)
%classifyRunSpeedSVR.m Classifies the running speed in the maze using an SVR
%
%INPUTS
%dataCell - dataCell containing imaging information
%
%OUTPUTS
%classifierOut - classifer structure
%
%ASM 4/15

nShuffles = 100;
shouldShuffle = false;
traceType = 'dff';
whichFactor = 2;
trainFrac = 0.5;
downsample = 1;
posControl = true; 
posBin = 60;

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
            case 'downsample'
                downsample = varargin{argInd+1};
            case 'poscontrol' 
                posControl = varargin{argInd+1};
            case 'posbin'
                posBin = varargin{argInd+1};
        end
    end
end

%get traces
[~,traces] = catBinnedTraces(dataCell);

%get binned data frames
binnedDF = catBinnedDataFrames(dataCell);

%filter by position
if posControl
    binnedDF = binnedDF(:,posBin,:);
    traces = traces(:,posBin,:);
end

%extract yPos
binnedXSpeed = binnedDF(5,:,:);
binnedYSpeed = binnedDF(5,:,:);
binnedRunSpeed = sqrt(binnedXSpeed(:).^2 + binnedYSpeed(:).^2);

%reshape to correct arrays 
realClass = binnedRunSpeed;
reTraces = reshape(traces,size(traces,1),[]);

%remove nans 
removeInd = isnan(realClass);
realClass(removeInd) = [];
reTraces(:,removeInd) = [];

%downsample
keepInd = randsample(length(realClass),round(length(realClass)/downsample));
realClass = realClass(keepInd);
reTraces = reTraces(:,keepInd);

%pad traces 
reTraces = permute(reTraces,[1 3 2]);

%get nTest
nTrials = length(realClass);
nTest = floor(nTrials*(1-trainFrac));


%calculate actual accuracy
[guess, testClass, mse, corrCoef] = getPositionSVR(reTraces,...
    realClass, trainFrac);

%shuffle
if shouldShuffle
    %initialize
    shuffleMSE = nan(nShuffles,1);
    shuffleGuess = nan(nTest,nShuffles);
    shuffleTestClass = nan(nTest,nShuffles);
    shuffleCorrCoef = nan(size(shuffleMSE));
    
    parfor shuffleInd = 1:nShuffles
        dispProgress('Performing shuffle %d/%d',shuffleInd,shuffleInd,nShuffles);
        %generate random netEv conditions
        randClass = shuffleArray(realClass);
        
        [shuffleGuess(:,shuffleInd), shuffleTestClass(:,shuffleInd),...
            shuffleMSE(shuffleInd),shuffleCorrCoef(shuffleInd)] =...
            getPositionSVR(reTraces,randClass,trainFrac);
    end
else
    shuffleMSE = [];
    shuffleCorrCoef = [];
    shuffleGuess = [];
    shuffleTestClass = [];
end

%save to classifier out
classifierOut.shuffleMSE = shuffleMSE;
classifierOut.shuffleCorrCoef = shuffleCorrCoef;
classifierOut.shuffleGuess = shuffleGuess;
classifierOut.shuffleTestClass = shuffleTestClass;
classifierOut.corrCoef = corrCoef;
classifierOut.mse = mse;
classifierOut.testClass = testClass;
classifierOut.guess = guess;
end

function [guess, testClass, mse, corrCoef] = getPositionSVR(traces,...
    realClass, trainFrac)

%calculate accuracy
[guess,mse,testClass,corrCoef] =...
    getSVMAccuracy(traces,realClass,...
    'svmType', 'e-SVR', 'C',50,'epsilon',0.004,'gamma',0.04,'kFold',1,...
    'trainFrac',trainFrac);
end