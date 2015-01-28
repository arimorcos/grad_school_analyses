function segVec = constructSegmentVector(dataCell,segRanges,segFunc)
%constructSegmentVector.m Creates a segment vector with size 1 x sum for
%all trials (nFrames) using the segment function provided
%
%INPUTS
%dataCell - dataCell to extract data from
%segRanges - 1 x nSeg+1 vector of segment ranges
%segFunc - function to extract values from. Should return in nTrials x nSeg
%
%OUTPUTS
%segVec - segment vector 
%
%ASM 11/14

%extract relevant information
if isa(segFunc,'function_handle')
    segVals = segFunc(dataCell);
else
    segVals = segFunc;
end

%get nSeg
nSeg = size(segVals,2);

%get yPos vector
if isfield(dataCell{1},'imaging') && isfield(dataCell{1}.imaging,'dataFrames')
    yPos = cell2mat(cellfun(@(x) x.imaging.dataFrames{1}(3,:),dataCell,'UniformOutput',false))';
else
    yPos = cell2mat(cellfun(@(x) x.binnedDat(3,:),dataCell,'UniformOutput',false))';
end

%find trial starts
trialStarts = [1; find(diff(yPos) < -600)+1];

%get nTrials
nTrials = length(dataCell);
if length(trialStarts) ~= nTrials
    error('Trial numbers don''t match');
end

%construct trialVec
trialVec = zeros(size(yPos));
for trialInd = 1:nTrials
    if trialInd < nTrials
        trialVec(trialStarts(trialInd):trialStarts(trialInd+1)-1) = trialInd;
    else
        trialVec(trialStarts(trialInd):end) = trialInd;
    end
end

%initialize segVec
segVec = zeros(size(yPos));

%loop through segments and assign values to each segment period
for segInd = 1:nSeg
    
    %loop through each trial
    for trialInd = 1:nTrials
        
        %find indices
        tempInd = yPos >= segRanges(segInd) &... %yPos greater than or equal to lower seg bound
            yPos < segRanges(segInd+1) &... %yPos less than upper seg bound
            trialVec == trialInd; %matches current trial
        
        %set tempInd to proper values
        segVec(tempInd) = segVals(trialInd,segInd);
    end
        
end