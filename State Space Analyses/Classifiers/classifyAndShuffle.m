function varargout = classifyAndShuffle(traces,realClass,toReturn,varargin)
%classifyAndShuffle.m Performs classification and a shuffle and returns
%requested arguments
%
%INPUTS
%traces - nNeurons x nBins x nTrials array of traces
%realClass - 1 x nTrials array of class for each trial. Each value should
%   be an integer
%toReturn - cell array of arguments to return. Valid options:
%   "accuracy"
%   "classGuess"
%   "shuffleAccuracy"
%   "shuffleGuess"
%   Default is {'accuracy','shuffleAccuracy'}
%
%OPTIONAL INPUTS
%dontCompareSame - don't compare trials within the same category specified
%   by an array provided after don't compare same
%testOffset - offset test by nBins. Default is 0
%nShuffles - number of shuffles to perform. Default is 100.
%
%OUTPUTS
%accuracy - 1 x nBins array of classifier accuracy as a percentage
%classGuess - nTrials x nBins array of classifier guesses
%shuffleAccuracy - nShuffles x nBins array of shuffle accuracy as
%   percentage
%shuffleGuess - nTrials x nBins x nShuffles array of shuffle guess
%
%ASM 1/15

%convert toReturn to cell if ischar
if ischar(toReturn)
    toReturn = {toReturn};
end

%process varargin
testOffset = 0;
dontCompareSame = [];
nShuffles = 100;
classifier = 'svm';

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'dontcomparesame'
                dontCompareSame = varargin{argInd+1};
            case 'testoffset'
                testOffset = varargin{argInd+1};
            case 'nshuffles'
                nShuffles = varargin{argInd+1};
            case 'classifier'
                classifier = varargin{argInd+1};
        end
    end
end

%call get classifier accuracy
switch classifier
    case 'svm'
        [accuracy,classGuess] = getSVMAccuracy(traces,realClass,'dontcomparesame',dontCompareSame);
    case 'leastdist'
        [accuracy,classGuess] = getClassifierAccuracyNew(traces,realClass,'dontcomparesame',dontCompareSame,...
            'testoffset',testOffset);
end

%shuffle
shuffleAccuracy = nan(nShuffles,length(accuracy));
shuffleGuess = nan(size(classGuess,1),size(classGuess,2),nShuffles);
parfor shuffleInd = 1:nShuffles
    %display progress
    dispProgress('Shuffling %d/%d',shuffleInd,shuffleInd,nShuffles);
    
    %shuffle labels
    shuffledClass = shuffleArray(realClass);
    
    switch classifier
        case 'svm'
            %classify
            [shuffleAccuracy(shuffleInd,:),shuffleGuess(:,:,shuffleInd)] =...
                getSVMAccuracy(traces,shuffledClass,...
                'dontcomparesame',dontCompareSame);
            
%             while any(shuffleAccuracy(shuffleInd,:) < 30)
%                 lowInd = shuffleAccuracy(shuffleInd,:) < 30;
%                 [shuffleAccuracy(shuffleInd,lowInd),shuffleGuess(:,lowInd,shuffleInd)] =...
%                     getSVMAccuracy(traces(:,lowInd,:),shuffleArray(shuffledClass),...
%                     'dontcomparesame',dontCompareSame);
%             end
        case 'leastdist'
            %classify
            [shuffleAccuracy(shuffleInd,:),shuffleGuess(:,:,shuffleInd)] =...
                getClassifierAccuracyNew(traces,shuffledClass,...
                'dontcomparesame',dontCompareSame,...
                'testoffset',testOffset);
            
%             while any(shuffleAccuracy(shuffleInd,:) < 30)
%                 lowInd = shuffleAccuracy(shuffleInd,:) < 30;
%                 [shuffleAccuracy(shuffleInd,lowInd),shuffleGuess(:,lowInd,shuffleInd)] =...
%                     getClassifierAccuracyNew(traces(:,lowInd,:),shuffleArray(shuffledClass),...
%                     'dontcomparesame',dontCompareSame,...
%                     'testoffset',testOffset);
%             end
    end
end

%handle varargout
varargout = cell(1,length(toReturn));
for outArgInd = 1:length(toReturn)
    switch lower(toReturn{outArgInd})
        case 'accuracy'
            varargout{outArgInd} = accuracy;
        case 'classguess'
            varargout{outArgInd} = classGuess;
        case 'shuffleaccuracy'
            varargout{outArgInd} = shuffleAccuracy;
        case 'shuffleguess'
            varargout{outArgInd} = shuffleGuess;
        otherwise
            error('Can''t interpret return argument: "%s"',toReturn{outArgInd})
    end
end
