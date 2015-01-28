function classifierOut = classifyNetEvIndSeg(dataCell,varargin)
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
traceType = 'dfffactor';
whichFactor = 2;
useMode = true;
range = [0.25 0.5];
conditions = {'','result.leftTurn==1','result.leftTurn==0'};

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
    
    if ~useMode %if take mean
        meanBinRange = round(range*size(segTraces,2));
        segTraces = mean(segTraces(:,meanBinRange(1):meanBinRange(2),:),2);
    end
    
    %get nSeg
    nSeg = max(segNum);
    
    %get nBins
    nBins = size(segTraces,2);
    
    %reshape netEv
    realClass = reshape(netEv,nTrials,nSeg);
    
    %calculate actual accuracy
    [accuracy,classGuess,realClass,distances,distClasses] =...
        getNetEvIndSegAcc(segTraces,nSeg,realClass,nBins,nTrials,useMode,range);
    
    %shuffle
    if shouldShuffle
        %initialize
        shuffleAccuracy = zeros(nSeg,1,nShuffles);
        shuffleGuess = zeros(nTrials,1,nSeg,nShuffles);
        plotShuffle = true;
        shuffleDistances = cell(1,nShuffles);
        
        for shuffleInd = 1:nShuffles
            dispProgress('Performing shuffle %d/%d',shuffleInd,shuffleInd,nShuffles);
            %generate random netEv conditions
            randClass = shuffleLabels(realClass);
            
            [shuffleAccuracy(:,:,shuffleInd),shuffleGuess(:,:,:,shuffleInd),~,shuffleDistances{shuffleInd}] =...
                getNetEvIndSegAcc(segTraces,nSeg,randClass,nBins,nTrials,useMode,range);
        end
    else
        shuffleAccuracy = [];
        shuffleGuess = [];
        plotShuffle = false;
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


function [accuracy,classGuess,realClass,distances,distClasses] = getNetEvIndSegAcc(segTraces,nSeg,...
    realClass,nBins,nTrials,useMode,range)

%initialize outputs
if useMode
    accuracy = zeros(nSeg,1);
    tempClassGuess = zeros(nTrials,nBins,nSeg);
    classGuess = zeros(nTrials,1,nSeg);
else
    accuracy = zeros(nSeg,nBins);
    classGuess = zeros(nTrials,nBins,nSeg);
end
distances = cell(1,nSeg);
distClasses = cell(1,nSeg);


%loop through each segment and get accuracy
for segInd = 1:nSeg
    %get trace indices
    traceInd = nTrials*(segInd-1)+1:nTrials*segInd;
    
    %fix accuracy if useMode
    if useMode
        %calculate accuracy
        [~,tempClassGuess(:,:,segInd),distances{segInd},distClasses{segInd}] =...
            getClassifierAccuracyNew(segTraces(:,:,traceInd),realClass(:,segInd));
        
        %get bin range
        binRange = round(range*nBins);
        
        [classGuess(:,1,segInd),freq] = mode(tempClassGuess(:,binRange(1):binRange(2),segInd),2);
        accuracy(segInd,1) = 100*sum(classGuess(:,1,segInd) == realClass(:,segInd))/size(classGuess,1);
        
        %sort distances
        distances{segInd}=mean(distances{segInd}(:,binRange(1):binRange(2),:),2);
    else
        %calculate accuracy
        [accuracy(segInd,:),classGuess(:,:,segInd)] =...
            getClassifierAccuracyNew(segTraces(:,:,traceInd),realClass(:,segInd));
    end
end

