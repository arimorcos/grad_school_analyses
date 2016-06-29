function classifierOut = classifyNetEvGroupSegSVM(dataCell,varargin)
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
traceType = 'deconv';
whichFactor = 2;
range = [0.5 0.75];
% conditions = {'','result.leftTurn==1','result.leftTurn==0'};
conditions = {''};
trainFrac = 0.75;
classMode = 'netEv';
trialMatch = false;
binViewAngle = false;
leftViewAngle = true;
viewAngleRange = 5;
whichNeurons = [];
trainInd = [];
breakTrialAssociation = false;
viewAngleSwap = false;
useBehaviorOnly = false;
useBehaviorAndNeuron = false;
do_not_train_33 = false;
C = 2;
epsilon = 0.0001;
gamma = 0.04;
limitSeg = [];

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'usebehavioronly'
                useBehaviorOnly = varargin{argInd+1};
            case 'usebehaviorandneuron'
                useBehaviorAndNeuron = varargin{argInd+1};
            case 'nshuffles'
                nShuffles = varargin{argInd+1};
            case 'shouldshuffle'
                shouldShuffle = varargin{argInd+1};
            case 'tracetype'
                traceType = varargin{argInd+1};
            case 'whichfactor'
                whichFactor = varargin{argInd+1};
            case 'breaktrialassociation'
                breakTrialAssociation = varargin{argInd+1};
            case 'classmode'
                classMode = varargin{argInd+1};
            case 'range'
                range = varargin{argInd+1};
            case 'conditions'
                conditions = varargin{argInd+1};
            case 'trialmatch'
                trialMatch = varargin{argInd+1};
            case 'binviewangle'
                binViewAngle = varargin{argInd+1};
            case 'leftviewangle'
                leftViewAngle = varargin{argInd+1};
            case 'viewanglerange'
                viewAngleRange = varargin{argInd+1};
            case 'whichneurons'
                whichNeurons = varargin{argInd+1};
            case 'trainind'
                trainInd = varargin{argInd+1};
            case 'viewangleswap'
                viewAngleSwap = varargin{argInd+1};
            case 'epsilon'
                epsilon = varargin{argInd+1};
            case 'gamma'
                gamma = varargin{argInd+1};
            case 'c'
                C = varargin{argInd+1};
            case 'limitseg'
                limitSeg = varargin{argInd+1};
            case 'do_not_train_33'
                do_not_train_33 = varargin{argInd+1};
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
    if useBehaviorOnly
        [segTraces,~,netEv,segNum,numLeft,~,~,leftTurn,viewAngle,~,leftTrial] = extractSegmentTraces(dataSub,'usebins',true,...
            'tracetype','behavior','whichFactor',whichFactor);
    elseif useBehaviorAndNeuron
        [segTraces,~,netEv,segNum,numLeft,~,~,leftTurn,viewAngle,~,leftTrial] = extractSegmentTraces(dataSub,'usebins',true,...
            'tracetype',traceType,'whichFactor',whichFactor);
        behavTraces= extractSegmentTraces(dataSub,'usebins',true,...
            'tracetype','behavior','whichFactor',whichFactor);
        segTraces = cat(1,segTraces,behavTraces);
    else
        [segTraces,~,netEv,segNum,numLeft,~,~,leftTurn,viewAngle,~,leftTrial] =...
            extractSegmentTraces(dataSub,'usebins',true,...
            'tracetype',traceType,'whichFactor',whichFactor);
    end
    
    %get nSeg
    nSeg = max(segNum);
    
    %filter neurons
    if ~isempty(whichNeurons)
        segTraces = segTraces(whichNeurons,:,:);
    end
    
    %take mean
    meanBinRange = round(range*size(segTraces,2));
    segTraces = mean(segTraces(:,meanBinRange(1):meanBinRange(2),:),2);
    
    %take subset if trial matching
    if trialMatch
        
        %generate random indices from 1:nSeg*nTrials
        keepInd = sort(randsample(nSeg*nTrials,nTrials));
        
        %filter
        segTraces = segTraces(:,:,keepInd);
        netEv = netEv(keepInd);
        segNum = segNum(keepInd);
        numLeft = numLeft(keepInd);
        leftTurn = leftTurn(keepInd);
        leftTrial = leftTrial(keepInd);
    else
        nTrials = nTrials*nSeg;
    end
    
    %view angle swap
    if viewAngleSwap
        
        swapGroup1 = 1:round(nTrials/2);
        swapGroup2 = swapGroup1(end)+1:nTrials;
        minDiff = nan(length(swapGroup1),1);
        for swap = swapGroup1
            testViewAngle = viewAngle(swap);
            diffViewAngle = abs(testViewAngle - viewAngle(swapGroup2));
            [minDiff(swap), minInd] = min(diffViewAngle);
            minIndTotal = swapGroup2(minInd);
            
            %swap
            tempNetEv = netEv(swap);
            netEv(swap) = netEv(minIndTotal);
            netEv(minIndTotal) = tempNetEv;
            
        end
    else
        minDiff = [];
        
    end
    
    
    %get view angle
    if binViewAngle
        
        if trialMatch
            error('Cannot use binViewAngle and trialMatch together');
        end
        
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
        segTraces = segTraces(:,:,keepInd);
        netEv = netEv(keepInd);
        segNum = segNum(keepInd);
        numLeft = numLeft(keepInd);
        nTrials = sum(keepInd);
        leftTurn = leftTurn(keepInd);
        leftTrial = leftTrial(keepInd);
    end
    
    % limit seg
    if ~isempty(limitSeg)
        keepInd = segNum == limitSeg;
        segTraces = segTraces(:,:,keepInd);
        netEv = netEv(keepInd);
        segNum = segNum(keepInd);
        numLeft = numLeft(keepInd);
        nTrials = sum(keepInd);
        leftTurn = leftTurn(keepInd);
        leftTrial = leftTrial(keepInd);
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
    
    % break trial association
    if breakTrialAssociation
        unique_classes = unique(realClass);
        num_classes = length(unique_classes);
        num_neurons = size(segTraces, 1);
        for class = 1:num_classes
            sub_ind = find(realClass == unique_classes(class));
            for neuron = 1:num_neurons
                segTraces(neuron, :, sub_ind) = segTraces(neuron, :, shuffleArray(sub_ind));
            end
        end
        
    end
    
    %specify train indices
    num_train = round(nTrials*trainFrac);
    allInd = shuffleArray(1:nTrials);
    trainInd = allInd(1:num_train);
    testInd = sort(allInd(num_train+1:end));
    
    %remove 3-3s from train ind
    if do_not_train_33
        remove_trials = find(numLeft == 3 & segNum == 6);
        if ~isempty(remove_trials)
            
            trainInd(ismember(trainInd, remove_trials)) = [];
            
            testInd = cat(2, testInd, remove_trials');
            testInd = sort(unique(testInd));
        end
    end
    
    %calculate actual accuracy
    [guess, testClass, mse, corrCoef] = getNetEvGroupSegData(segTraces,...
        realClass, trainFrac, trainInd, epsilon, gamma, C);
    
    %subset
    segNum = segNum(testInd);
    leftTurn = leftTurn(testInd);
    leftTrial = leftTrial(testInd);
    correct = leftTurn == leftTrial;
    
    %shuffle
    if shouldShuffle
        %initialize
        shuffleMSE = nan(nShuffles,1);
        shuffleGuess = nan(nTest,nShuffles);
        shuffleTestClass = nan(nTest,nShuffles);
        shuffleCorrCoef = nan(size(shuffleMSE));
        
        for shuffleInd = 1:nShuffles
            %             dispProgress('Performing shuffle %d/%d',shuffleInd,shuffleInd,nShuffles);
            %generate random netEv conditions
            randClass = shuffleArray(realClass);
            
            [shuffleGuess(:,shuffleInd), shuffleTestClass(:,shuffleInd),...
                shuffleMSE(shuffleInd),shuffleCorrCoef(shuffleInd)] =...
                getNetEvGroupSegData(segTraces,randClass,trainFrac,trainInd,...
                epsilon, gamma, C);
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
    classifierOut(condInd).binViewAngle = binViewAngle;
    classifierOut(condInd).leftViewAngle = leftViewAngle;
    classifierOut(condInd).viewAngleRange = viewAngleRange;
    classifierOut(condInd).minDiff = minDiff;
    classifierOut(condInd).correct = correct;
    classifierOut(condInd).leftTurn = leftTurn;
    classifierOut(condInd).leftTrial = leftTrial;
    classifierOut(condInd).segNum = segNum;
end

function [guess, testClass, mse, corrCoef] = getNetEvGroupSegData(segTraces,...
    realClass, trainFrac, trainInd, epsilon, gamma, C)

%calculate accuracy
[guess,mse,testClass,corrCoef] =...
    getSVMAccuracy(segTraces,realClass,...
    'svmType', 'e-SVR', 'CParam',C,...
    'epsilon',epsilon,'gamma',gamma,'kFold',1,...
    'trainFrac',trainFrac,'trainind',trainInd);


