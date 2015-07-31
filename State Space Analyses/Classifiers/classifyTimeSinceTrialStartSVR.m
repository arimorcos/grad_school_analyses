function classifierOut = classifyTimeSinceTrialStartSVR(dataCell,varargin)
%classifyTimeSinceTrialStartSVR.m Classifies the time since trial start for
%every bin 
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
% traceType = 'dff';
% whichFactor = 2;
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
        end
    end
end

%get traces
[~,traces] = catBinnedTraces(dataCell);

%get binned data frames
binnedDF = catBinnedDataFrames(dataCell);

%get times 
binTimes = squeeze(binnedDF(1,:,:));

%get trial starts
trialStarts = getCellVals(dataCell,'time.start');

%crop 
binTimes = binTimes(2:end-1,:);
traces = traces(:,2:end-1,:);
nBins = size(traces,2);

%get time since trial start 
timeSinceStartVec = datevec(bsxfun(@minus,binTimes,trialStarts));
timeSinceStart = 3600*timeSinceStartVec(:,4) + 60*timeSinceStartVec(:,5) + ...
    timeSinceStartVec(:,6);
timeSinceStart = reshape(timeSinceStart,size(binTimes));

%get nTest
nTrials = size(traces,3);
nTest = floor(nTrials*(1-trainFrac));

%calculate actual accuracy at each bin 
guess = nan(nTest,nBins);
testClass = nan(nTest,nBins);
% mse = nan(nTest,nBins);
% corrCoef = nan(nTest,nBins);
guessCorr = nan(nBins,1);
for bin = 1:nBins
    [guess(:,bin), testClass(:,bin), ~, ~] = getPositionSVR(traces(:,bin,:),...
        timeSinceStart(bin,:), trainFrac);
    tempCorr = corrcoef(guess(:,bin),testClass(:,bin));
    guessCorr(bin) = tempCorr(1,2);
end

%shuffle
if shouldShuffle
    %initialize
    %     shuffleMSE = nan(nShuffles,1);
    shuffleGuess = nan(nTest,nBins,nShuffles);
    shuffleTestClass = nan(nTest,nBins,nShuffles);
    shuffleCorr = nan(nBins,nShuffles);
    %     shuffleCorrCoef = nan(size(shuffleMSE));
    
    parfor shuffleInd = 1:nShuffles
        dispProgress('Performing shuffle %d/%d',shuffleInd,shuffleInd,nShuffles);
        for bin = 1:nBins
            %generate random netEv conditions
            randClass = shuffleArray(timeSinceStart(bin,:));
            
            [shuffleGuess(:,bin,shuffleInd), shuffleTestClass(:,bin,shuffleInd),...
                ~,~] =...  
                getPositionSVR(traces(:,bin,:),randClass,trainFrac);
            
            tempCorr = corrcoef(shuffleGuess(:,bin,shuffleInd),...
                shuffleTestClass(:,bin,shuffleInd));
            shuffleCorr(bin,shuffleInd) = tempCorr(1,2);
        end
    end
else
%     shuffleMSE = [];
%     shuffleCorrCoef = [];
    shuffleGuess = [];
    shuffleTestClass = [];
    shuffleCorr = [];
end

%save to classifier out
% classifierOut.shuffleMSE = shuffleMSE;
% classifierOut.shuffleCorrCoef = shuffleCorrCoef;
classifierOut.shuffleGuess = shuffleGuess;
classifierOut.shuffleTestClass = shuffleTestClass;
classifierOut.shuffleCorr = shuffleCorr;
% classifierOut.corrCoef = corrCoef;
% classifierOut.mse = mse;
classifierOut.guessCorr = guessCorr;
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