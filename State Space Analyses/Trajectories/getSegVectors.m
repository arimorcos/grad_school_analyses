function segVectorTable = getSegVectors(traces,mazePatterns,varargin)
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
assert(size(traces,3) == size(mazePatterns,1),['mazePatterns and traces must'...
    ' contain the same number of trials']);

%assert that vectorRange between 0 and 1 
assert(all(vectorRange >= 0 & vectorRange <= 1),'vectorRange must be between 0 and 1');

%get net evidence 
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
for segNum = 1:nSeg
    
    %get trial indices
    trialInds = nTrials*(segNum-1)+1:nTrials*segNum;
    
    %extract and store
    segTraces(:, :, trialInds) = traces(:,binNums(segNum):binNums(segNum+1)-1,:);
    
end

%get binRange for vectors 
vectorBinRange = round(vectorRange*nBinsPerSeg);
vectorBinRange = max(1,vectorBinRange);

%get vectors (nDim x nSegTrials)
segVectors = squeeze(segTraces(:,vectorBinRange(2),:) - segTraces(:,vectorBinRange(1),:)); 

%convert segVectors to 1 x nSegTrials cell array 
segVectors = num2cell(segVectors,1)';

%reshape mazePatterns and netEvidence 
mazePatterns = mazePatterns(:);
netEvidence = netEvidence(:);

%create segNum 
segNum = repmat(1:nSeg,nTrials,1);
segNum = segNum(:);

%create table 
segVectorTable = table(segVectors, mazePatterns, netEvidence, segNum,...
    'VariableNames',{'vector','segID','netEv','segNum'});