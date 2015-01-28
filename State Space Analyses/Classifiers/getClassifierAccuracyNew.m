function [accuracy,classGuess,distances,classes] = getClassifierAccuracyNew(traces,realClass,varargin)
%getClassifierAccuracyNew Rewritten function to determine classifier
%accuracy for an arbitrary class designation
%
%INPUTS
%traces - nNeurons x nBins x nTrials array of traces
%realClass - 1 x nTrials array of class for each trial. Each value should
%   be an integer
%
%OUTPUTS
%accuracy - 1 x nBins array of classifier accuracy as a percentage 
%classGuess - nTrials x nBins array of classifier guesses 
%
%ASM 9/14

shouldntCompareSame = false;
sameClass = [];

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'dontcomparesame'
               shouldntCompareSame = true;
               sameClass = varargin{argInd+1};
        end
    end
end

%get number of trials and bins
[nNeurons, nBins, nTrials] = size(traces);

%get classes
classes = unique(realClass);
nClasses = length(classes);

%initialize classGuess
classGuess = zeros(nTrials,nBins);

%initialize distances
distances = zeros(nClasses,nBins,nTrials);

%initialize allTrials
allTrials = 1:nTrials;

%loop through each trial
for trialInd = allTrials
    
    %get train indices
    trainInd = allTrials;
    trainInd(trialInd) = [];
    
    %remove same trials if should
    if shouldntCompareSame
        %get class of current trial
        currClass = sameClass(trialInd);
        
        %get tempSameClass by removing trialInd
        tempSameClass = sameClass;
        tempSameClass(trialInd)=[];
        
        %remove trials of same class
        trainInd = trainInd(tempSameClass~=currClass);
    end
    
    %get isolated traces
    testTrace = traces(:,:,trialInd);
    trainTraces = traces(:,:,trainInd);
    tempClassIDs = realClass(trainInd);
    
    %initialize class means
    tempClassMeans = zeros(nNeurons,nBins,nClasses);
    
    %initialize distances
    tempDistances = zeros(nClasses,nBins);
    
    %loop through each class and generate mean trace for each class type at
    %every bin, then calculate the distance to that mean
    for classInd = 1:nClasses
        
        %get ind of trials which match class
        matchTrials = tempClassIDs == classes(classInd);
        
        %take mean of matchTrials
        tempClassMeans(:,:,classInd) = mean(trainTraces(:,:,matchTrials),3);
        
        %get distance for each bin
        tempDistances(classInd,:) = arrayfun(@(x) ...
            calcEuclidianDist(testTrace(:,x),tempClassMeans(:,x,classInd)),1:nBins);
        
    end
    
    %make a class guess
    [~,guessInd] = min(tempDistances);
    classGuess(trialInd,:) = classes(guessInd);
    
    %store distances
    distances(:,:,trialInd) = tempDistances;
   
end

%calculate accuracy
if ~iscolumn(realClass);realClass = realClass';end %convert to column vector
correctGuess = sum(repmat(realClass,1,nBins)==classGuess);
accuracy = correctGuess./nTrials;
accuracy = accuracy*100;