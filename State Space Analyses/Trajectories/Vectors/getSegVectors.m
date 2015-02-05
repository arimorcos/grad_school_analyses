function segVectorTable = getSegVectors(traces,dataCell,varargin)
%getSegVectors.m Extracts segment vectors from traces array 
%
%INPUTS
%traces - nFactors/nNeurons x nBins x nTrials array 
%mazePatterns - nTrials x nSeg array of mazePatterns 
%
%OPTIONAL INPUTS
%binNums - 1 x nSeg + 1 array of binNumbers for start and stop of each
%   segment
%vectorRange - 1 x 2 array of fraction start and end bin for vector
%   calculation. Must be between 0 and 1
%
%OUTPUTS
%segVectorTable - nTrials x nSeg table containing information about each
%   semgent vector
%
%ASM 1/15

offset = 1; %allows to use last bin of previous segment

%process varargin
binNums = [10 26 42 58 74 90 106];
vectorRange = [0 1];

if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'binnums'
                binNums = varargin{argInd+1};
            case 'vectorrange'
                vectorRange = varargin{argInd+1};
        end
    end
end

%assert that trial numbers in maze patterns match those in traces
assert(size(traces,3) == size(dataCell,2),['mazePatterns and traces must'...
    ' contain the same number of trials']);

%assert that vectorRange between 0 and 1 
assert(all(vectorRange >= 0 & vectorRange <= 1),'vectorRange must be between 0 and 1');

%get net evidence
mazePatterns = getMazePatterns(dataCell);
netEvidence = getNetEvidence(mazePatterns);

%get nTrials, nSeg, and nDim
[nTrials, nSeg] = size(mazePatterns);
nDim = size(traces,1);

%get nBinsPerSeg
nBinsPerSeg = unique(diff(binNums));
assert(length(nBinsPerSeg) == 1,'Each segment must have an equivalent number of bins');

%get total segTrials
nSegTrials = nTrials*nSeg;

%reshape traces into nDim x nBins x nSegTrials
segTraces = nan(nDim, nBinsPerSeg, nSegTrials);
% prevPatt = cell(nSegTrials,1);
for segNum = 1:nSeg
    
    %get trial indices
    trialInds = nTrials*(segNum-1)+1:nTrials*segNum;
    
    %extract and store
    segTraces(:, :, trialInds) = traces(:,binNums(segNum)-offset:binNums(segNum+1)-1-offset,:);
    
    %get previous pattern
%     prevPatterns = nan(size(mazePatterns));
%     prevPatterns(:,(nSeg-segNum+2):nSeg) = mazePatterns(:,1:(segNum-1));
%     prevPatt(trialInds) = num2cell(prevPatterns,2);
    
end

%get binRange for vectors 
vectorBinRange = round(vectorRange*nBinsPerSeg);
vectorBinRange = max(1,vectorBinRange);

%get vectors (nDim x nSegTrials)
segVectors = squeeze(segTraces(:,vectorBinRange(2),:) - segTraces(:,vectorBinRange(1),:)); 

%convert segVectors to 1 x nSegTrials cell array 
segVectors = num2cell(segVectors,1)';

%get prevSeg
prevSeg = mazePatterns(:,1:nSeg-1);
prevSeg = cat(2,-100*ones(nTrials,1),prevSeg);
prevSeg = prevSeg(:);

%get prevSeg
prevSeg2 = mazePatterns(:,1:nSeg-2);
prevSeg2 = cat(2,repmat(-100*ones(nTrials,1),1,2),prevSeg2);
prevSeg2 = prevSeg2(:);

%get leftTrial
leftTrial = getCellVals(dataCell,'maze.leftTrial');
leftTrial = repmat(leftTrial,1,nSeg);
leftTrial = leftTrial(:);

%get prevTurn
prevTurn = getCellVals(dataCell,'result.prevTurn');
prevTurn = repmat(prevTurn,1,nSeg);
prevTurn = prevTurn(:);

%get prevCorrect
prevCorrect = getCellVals(dataCell,'result.prevCorrect');
prevCorrect = repmat(prevCorrect,1,nSeg);
prevCorrect = prevCorrect(:);

%get prevCrutch
prevCrutch = getCellVals(dataCell,'result.prevCrutch');
prevCrutch = repmat(prevCrutch,1,nSeg);
prevCrutch = prevCrutch(:);

%reshape mazePatterns and netEvidence 
mazePatterns = mazePatterns(:);
netEvidence = netEvidence(:);

%create segNum 
segNum = repmat(1:nSeg,nTrials,1);
segNum = segNum(:);

%create table 
segVectorTable = table(segVectors, mazePatterns, netEvidence, segNum, prevSeg,...
    prevSeg2, leftTrial, prevTurn, prevCorrect, prevCrutch,...
    'VariableNames',{'vector','segID','netEv','segNum','prevSeg',...
    'prevSeg2','leftTrial','prevTurn','prevCorrect','prevCrutch'});