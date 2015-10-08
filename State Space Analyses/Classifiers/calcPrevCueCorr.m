function out = calcPrevCueCorr(dataCell, varargin)
%calcPrevCueCorr.m Calculates the correlation coefficients between the
%population activity when the previous cue is the same or different,
%controlled for current cue and net evidence.
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OPTIONAL INPUTS
%trialMatch - whether to match the number of trials across LRL and RLL and
%   the corresponding right pair (RLR vs. LRR)
%traceType - which traces to use
%shouldShuffle - should shuffle
%nShuffles - number of shuffles, default is 500
%useCosine - use cosine similarity instead of correlation
%controlPrevTurn - control for the previous turn
%intraOnlyPrevTurn - only control for the previous turn in the intra case
%
%OUTPUTS
%out - structure containing:
%   allIntraLeft - all the intra correlations for LRL vs. RLL
%   allInterLeft - all the inter correlations for LRL vs. RLL
%   allIntraRight - all the intra correlations for LRR vs. RLR
%   allInterRight - all the inter correlations for LRR vs. RLR
%   allInter - all the inter correlations for both left and right
%   allIntra - all the intra correlations for both left and right
%
%ASM 10/15

trialMatch = false;
traceType = 'deconv';
useCosine = false;
controlPrevTurn = false;
intraOnlyPrevTurn = false;
shouldShuffle = true;
nShuffles = 500;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'trialmatch'
                trialMatch = varargin{argInd+1};
            case 'tracetype'
                traceType = varargin{argInd+1};
            case 'usecosine'
                useCosine = varargin{argInd+1};
            case 'controlprevturn'
                controlPrevTurn = varargin{argInd+1};
            case 'intraonlyprevturn'
                intraOnlyPrevTurn = varargin{argInd+1};
            case 'nshuffles'
                nShuffles = varargin{argInd+1};
            case 'shouldshuffle'
                shouldShuffle = varargin{argInd+1};
        end
    end
end

%get mazePatterns
mazePatterns = getMazePatterns(dataCell);

%get traces
switch lower(traceType)
    case 'deconv'
        traces = catBinnedDeconvTraces(dataCell);
    case 'dff'
        [~,traces] = catBinnedTraces(dataCell);
    otherwise
        error('Can''t interpret traceType: %s', traceType);
end

%get trace points
tracePoints = getMazePoints(traces, dataCell{1}.imaging.yPosBins);

if useCosine
    distForm = 'cosine';
else
    distForm = 'correlation';
end

if controlPrevTurn
    %get prev turn
    prevTurn = logical(getCellVals(dataCell,'result.prevTurn'))';
    
    %run for prevLeft
    [allIntraLeftPrevLeft, allIntraRightPrevLeft, allInterLeftPrevLeft,...
        allInterRightPrevLeft, allGuessPrevLeft, allLabelPrevLeft,...
        allGuessShufflePrevLeft, allLabelShufflePrevLeft] =...
        getTrialCorrelations(mazePatterns(prevTurn,:), tracePoints(:,:,prevTurn),...
        distForm, trialMatch, shouldShuffle, nShuffles);
    
    %run for prevRight
    [allIntraLeftPrevRight, allIntraRightPrevRight, allInterLeftPrevRight,...
        allInterRightPrevRight, allGuessPrevRight, allLabelPrevRight,...
        allGuessShufflePrevRight, allLabelShufflePrevRight] =...
        getTrialCorrelations(mazePatterns(~prevTurn,:), tracePoints(:,:,~prevTurn),...
        distForm, trialMatch, shouldShuffle, nShuffles);
    
    %combine
    allIntraLeft = cat(1, allIntraLeftPrevLeft, allIntraLeftPrevRight);
    allInterLeft = cat(1, allInterLeftPrevLeft, allInterLeftPrevRight);
    allIntraRight = cat(1, allIntraRightPrevLeft, allIntraRightPrevRight);
    allInterRight = cat(1, allInterRightPrevLeft, allInterRightPrevRight);
    allGuess = cat(1, allGuessPrevLeft, allGuessPrevRight);
    allLabel = cat(1, allLabelPrevLeft, allLabelPrevRight);
    allGuessShuffle = cat(1, allGuessShufflePrevLeft, allGuessShufflePrevRight);
    allLabelShuffle = cat(1, allLabelShufflePrevLeft, allLabelShufflePrevRight);
    
    
    if intraOnlyPrevTurn
        [~, ~, allInterLeft, allInterRight] =...
            getTrialCorrelations(mazePatterns, tracePoints, distForm, trialMatch,...
            shouldShuffle, nShuffles);
    end
else
    [allIntraLeft, allIntraRight, allInterLeft, allInterRight, allGuess, allLabel,...
        allGuessShuffle, allLabelShuffle] =...
        getTrialCorrelations(mazePatterns, tracePoints, distForm, trialMatch,...
        shouldShuffle, nShuffles);
end

out.allIntraLeft = allIntraLeft;
out.allInterLeft = allInterLeft;
out.allIntraRight = allIntraRight;
out.allInterRight = allInterRight;
out.allInter = cat(1, allInterRight, allInterLeft);
out.allIntra = cat(1, allIntraRight, allIntraLeft);
out.controlPrevTurn = controlPrevTurn;
out.allGuess = allGuess;
out.allLabel = allLabel;
out.allGuessShuffle = allGuessShuffle;
out.allLabelShuffle = allLabelShuffle;

end

function [allIntraLeft, allIntraRight, allInterLeft, allInterRight,...
    allGuess, allLabel, allGuessShuffle, allLabelShuffle] =...
    getTrialCorrelations(mazePatterns, tracePoints, distForm, trialMatch,...
    shouldShuffle, nShuffles)

thresh = 2;

%initialize
allIntraLeft = [];
allIntraRight = [];
allInterLeft = [];
allInterRight = [];
allGuess = [];
allLabel = [];
allGuessShuffle = [];
allLabelShuffle = [];

for segNum = 3:6
    
    % get matching trial pairs
    [LRLTrials, RLLTrials, RLRTrials, LRRTrials] = ...
        findHistoryPairs(mazePatterns,segNum);
    
    %ensure trial match
    if trialMatch
        LRLTrials = LRLTrials(1:min(length(LRLTrials),length(RLLTrials)));
        RLLTrials = RLLTrials(1:min(length(LRLTrials),length(RLLTrials)));
        LRRTrials = LRRTrials(1:min(length(LRRTrials),length(RLRTrials)));
        RLRTrials = RLRTrials(1:min(length(LRRTrials),length(RLRTrials)));
    end
    
    %% calculate left correlations
    LRLTraces = squeeze(tracePoints(:, segNum+1, LRLTrials))';
    RLLTraces = squeeze(tracePoints(:, segNum+1, RLLTrials))';
    
    % calculate intra correlations
    intraLRL = 1 - pdist(LRLTraces, distForm)';
    intraRLL = 1 - pdist(RLLTraces, distForm)';
    allIntraLeft = cat(1, allIntraLeft, intraLRL, intraRLL);
    
    % calculate inter correlations
    interLeft = 1 - pdist2(LRLTraces, RLLTraces, distForm);
    allInterLeft = cat(1, allInterLeft, interLeft(:));
    
    %classify
    [guessL, labelsL] = getAcc(LRLTrials, RLLTrials, thresh, intraLRL,...
        intraRLL, interLeft);
    allGuess = cat(1, allGuess, guessL);
    allLabel = cat(1, allLabel, labelsL);
    
    %shuffle
    if shouldShuffle
        tempGuessShuffle = [];
        tempLabelShuffle = [];
        for shuffleInd = 1:nShuffles
            %shuffle matrices 
            [shuffleIntraLRL, shuffleIntraRLL, shuffleInterLeft] = ...
                shuffleCorrMat(intraLRL, intraRLL, interLeft);
            
            %get shufled accuracies
            [shuffleGuessL, shuffleLabelsL] = getAcc(...
                LRLTrials, RLLTrials, thresh, shuffleIntraLRL,...
                shuffleIntraRLL, shuffleInterLeft);
            
            %concatenate
            tempGuessShuffle = cat(2, tempGuessShuffle, shuffleGuessL);
            tempLabelShuffle = cat(2, tempLabelShuffle, shuffleLabelsL);
        end
        allGuessShuffle = cat(1, allGuessShuffle, tempGuessShuffle);
        allLabelShuffle = cat(1, allLabelShuffle, tempLabelShuffle);
    end
    %     nLRLTrials = length(LRLTrials);
%     nRLLTrials = length(RLLTrials);
%     if nLRLTrials > thresh && nRLLTrials > thresh
%         nLTrials = nLRLTrials + nRLLTrials;
%         labelsL = zeros(nLTrials,1);
%         labelsL(1:length(LRLTrials)) = 1;
%         squareIntraLRL = squareform(intraLRL);
%         squareIntraRLL = squareform(intraRLL);
%         guessLRL = nan(nLRLTrials, 1);
%         guessRLL = nan(nRLLTrials, 1);
%         
%         for lrlTrial = 1:nLRLTrials
%             useInd = setdiff(1:nLRLTrials, lrlTrial);
%             meanIntra = mean(squareIntraLRL(lrlTrial,useInd));
%             
%             meanInter = mean(interLeft(lrlTrial,:));
%             
%             guessLRL(lrlTrial) = meanIntra > meanInter;
%         end
%         
%         for rllTrial = 1:nRLLTrials
%             useInd = setdiff(1:nRLLTrials, rllTrial);
%             meanIntra = mean(squareIntraRLL(rllTrial,useInd));
%             
%             meanInter = mean(interLeft(:,rllTrial));
%             
%             guessRLL(rllTrial) = meanIntra < meanInter;
%         end
%         
%         allGuess = cat(1, allGuess, guessLRL, guessRLL);
%         allLabel = cat(1, allLabel, labelsL);
%     end
    %% calculate right correlations
    LRRTraces = squeeze(tracePoints(:, segNum+1, LRRTrials))';
    RLRTraces = squeeze(tracePoints(:, segNum+1, RLRTrials))';
    
    % calculate intra correlations
    intraLRR = 1 - pdist(LRRTraces, distForm)';
    intraRLR = 1 - pdist(RLRTraces, distForm)';
    allIntraRight = cat(1, allIntraRight, intraLRR, intraRLR);
    
    % calculate inter correlations
    interRight = 1 - pdist2(LRRTraces, RLRTraces, distForm);
    allInterRight = cat(1, allInterRight, interRight(:));
    
    %classify
    [guessR, labelsR] = getAcc(LRRTrials, RLRTrials, thresh, intraLRR,...
        intraRLR, interRight);
    allGuess = cat(1, allGuess, guessR);
    allLabel = cat(1, allLabel, labelsR);
    
    %shuffle
    if shouldShuffle
        tempGuessShuffle = [];
        tempLabelShuffle = [];
        for shuffleInd = 1:nShuffles
            %shuffle matrices 
            [shuffleIntraLRR, shuffleIntraRLR, shuffleInterRight] = ...
                shuffleCorrMat(intraLRR, intraRLR, interRight);
            
            %get shufled accuracies
            [shuffleGuessR, shuffleLabelsR] = getAcc(...
                LRRTrials, RLRTrials, thresh, shuffleIntraLRR,...
                shuffleIntraRLR, shuffleInterRight);
            
            %concatenate
            tempGuessShuffle = cat(2, tempGuessShuffle, shuffleGuessR);
            tempLabelShuffle = cat(2, tempLabelShuffle, shuffleLabelsR);
        end
        allGuessShuffle = cat(1, allGuessShuffle, tempGuessShuffle);
        allLabelShuffle = cat(1, allLabelShuffle, tempLabelShuffle);
    end
%     nLRRTrials = length(LRRTrials);
%     nRLRTrials = length(RLRTrials);
%     if nLRRTrials > thresh && nRLRTrials > thresh
%         nRTrials = nLRRTrials + nRLRTrials;
%         labelsR = zeros(nRTrials,1);
%         labelsR(1:length(LRRTrials)) = 1;
%         squareIntraLRR = squareform(intraLRR);
%         squareIntraRLR = squareform(intraRLR);
%         guessLRR = nan(nLRRTrials, 1);
%         guessRLR = nan(nRLRTrials, 1);
%         
%         for lrrTrial = 1:nLRRTrials
%             useInd = setdiff(1:nLRRTrials, lrrTrial);
%             meanIntra = mean(squareIntraLRR(lrrTrial,useInd));
%             
%             meanInter = mean(interRight(lrrTrial,:));
%             
%             guessLRR(lrrTrial) = meanIntra > meanInter;
%         end
%         
%         for rlrTrial = 1:nRLRTrials
%             useInd = setdiff(1:nRLRTrials, rlrTrial);
%             meanIntra = mean(squareIntraRLR(rlrTrial,useInd));
%             
%             meanInter = mean(interRight(:,rlrTrial));
%             
%             guessRLR(rlrTrial) = meanIntra < meanInter;
%         end
%         
%         allGuess = cat(1, allGuess, guessLRR, guessRLR);
%         allLabel = cat(1, allLabel, labelsR);
%     end
end
end

function [guess, labels] = getAcc(LRLTrials, RLLTrials, thresh, intraLRL, ...
    intraRLL, interLeft)

guess=  [];
labels = [];


nLRLTrials = length(LRLTrials);
nRLLTrials = length(RLLTrials);
if nLRLTrials > thresh && nRLLTrials > thresh
    nLTrials = nLRLTrials + nRLLTrials;
    labels = zeros(nLTrials,1);
    labels(1:length(LRLTrials)) = 1;
    squareIntraLRL = squareform(intraLRL);
    squareIntraRLL = squareform(intraRLL);
    guessLRL = nan(nLRLTrials, 1);
    guessRLL = nan(nRLLTrials, 1);
    
    for lrlTrial = 1:nLRLTrials
        useInd = setdiff(1:nLRLTrials, lrlTrial);
        meanIntra = mean(squareIntraLRL(lrlTrial,useInd));
        
        meanInter = mean(interLeft(lrlTrial,:));
        
        guessLRL(lrlTrial) = meanIntra > meanInter;
    end
    
    for rllTrial = 1:nRLLTrials
        useInd = setdiff(1:nRLLTrials, rllTrial);
        meanIntra = mean(squareIntraRLL(rllTrial,useInd));
        
        meanInter = mean(interLeft(:,rllTrial));
        
        guessRLL(rllTrial) = meanIntra < meanInter;
    end
    
    guess = cat(1, guessLRL, guessRLL);
end
end

function [shuffleIntraLRL, shuffleIntraRLL, shuffleInter] = ...
    shuffleCorrMat(intraLRL, intraRLL, interLeft)

%combine all values 
allVal = cat(1, intraLRL, intraRLL, interLeft(:));

%shuffle 
shuffleVal = shuffleArray(allVal);

%get sizes 
nLRL = numel(intraLRL);
nRLL = numel(intraRLL);

%reshape 
shuffleIntraLRL = reshape(shuffleVal(1:nLRL), size(intraLRL));
shuffleIntraRLL = reshape(shuffleVal(nLRL+1:(nLRL + nRLL)), size(intraRLL));
shuffleInter = reshape(shuffleVal((nLRL + nRLL + 1):end), size(interLeft));

end