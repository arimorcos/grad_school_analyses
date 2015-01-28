function classifierOut = classifyNetEvAcrossSeg(dataCell,varargin)
%classifyNetEvAcrossSeg.m Classifies which net evidence condition a given bin
%of each segment is. Classifies only across segments (not within the same
%segment)
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
%ASM 10/14


nShuffles = 100;
shouldShuffle = false;
traceType = 'dfffactor';
whichFactor = 2;
useMode = true;
range = [0.25 0.5];
conditions = {'','result.leftTurn==1','result.leftTurn==0'};
subsetMatchInd = false;

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
            case 'subsetmatchind'
                subsetMatchInd = varargin{argInd+1};
        end
    end
end

%loop through each condition
for condInd = 1:length(conditions)
    
    %filter subset
    dataSub = getTrials(dataCell,conditions{condInd});
    
    %get segTraces
    [segTraces,~,netEv,segNum,~,~] = extractSegmentTraces(dataSub,'usebins',true,...
        'tracetype',traceType,'whichFactor',whichFactor);
    
    %get nTrials
    nTrials = length(dataSub);
    
    %subset if necessary
    if subsetMatchInd
        %generate indices
        randInd = randperm(size(segTraces,3),nTrials);
        
        %subset
        segTraces = segTraces(:,:,randInd);
        segNum = segNum(randInd);
        netEv = netEv(randInd);
    end
    
    if ~useMode %if take mean
        meanBinRange = round(range*size(segTraces,2));
        segTraces = mean(segTraces(:,meanBinRange(1):meanBinRange(2),:),2);
    end
    
    %get nBins
    [~,nBins,nTrials] = size(segTraces);
    
    %reshape netEv
    realClass = netEv;
    
    %calculate actual accuracy
    [accuracy,classGuess,realClass,distances,distClasses] =...
        getNetEvAcrossSegAcc(segTraces,realClass,nBins,nTrials,useMode,range,segNum);
    
    %shuffle
    if shouldShuffle
        %initialize
        shuffleAccuracy = zeros(1,nShuffles);
        shuffleGuess = zeros(nTrials,1,nShuffles);
        shuffleDistances = cell(1,nShuffles);
        
        for shuffleInd = 1:nShuffles
            dispProgress('Performing shuffle %d/%d',shuffleInd,shuffleInd,nShuffles);
            %generate random netEv conditions
            randClass = shuffleLabels(realClass);
            
            [shuffleAccuracy(:,shuffleInd),shuffleGuess(:,:,shuffleInd),~,shuffleDistances{shuffleInd}] =...
                getNetEvAcrossSegAcc(segTraces,randClass,nBins,nTrials,useMode,range,segNum);
        end
    else
        shuffleAccuracy = [];
        shuffleGuess = [];
        shuffleDistances = {};
    end
    
    %save to classifier out
    classifierOut(condInd).shuffleAccuracy = shuffleAccuracy;
    classifierOut(condInd).shuffleGuess = shuffleGuess;
    classifierOut(condInd).accuracy = accuracy;
    classifierOut(condInd).classGuess = classGuess;
    classifierOut(condInd).realClass = realClass;
    classifierOut(condInd).shuffleDistances = shuffleDistances;
    classifierOut(condInd).distances = distances;
    classifierOut(condInd).distClasses = distClasses;
    
end



function randClass = shuffleLabels(realClass)

randClass = zeros(size(realClass));

for i = 1:size(realClass,2) %for each segment
    randClass(:,i) = randsample(realClass(:,i),size(realClass,1));
end


function [accuracy,classGuess,realClass,distances,distClasses] = getNetEvAcrossSegAcc(segTraces,...
    realClass,nBins,nTrials,useMode,range,segNum)

%initialize outputs
if useMode
    accuracy = zeros(1,1);
    tempClassGuess = zeros(nTrials,nBins);
    classGuess = zeros(nTrials,1,1);
else
    accuracy = zeros(1,nBins);
    classGuess = zeros(nTrials,nBins);
end


%loop through each segment and get accuracy

%fix accuracy if useMode
if useMode
    %calculate accuracy
    [~,tempClassGuess,distances,distClasses] =...
        getClassifierAccuracyNew(segTraces,realClass,'dontcomparesame',segNum);
    
    %get bin range
    binRange = round(range*nBins);
    
    [classGuess(:,1)] = mode(tempClassGuess(:,binRange(1):binRange(2)),2);
    accuracy = 100*sum(classGuess(:,1) == realClass)/size(classGuess,1);
    
    %sort distances
    distances=mean(distances(:,binRange(1):binRange(2),:),2);
else
    %calculate accuracy
    [accuracy,classGuess(:,:)] =...
        getClassifierAccuracyNew(segTraces,realClass,'dontcomparesame',segNum);
end

