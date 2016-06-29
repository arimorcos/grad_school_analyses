function [segTraces,segId,netEv,segNum,numLeft,runSpeed,...
    delayTraces,turn,viewAngle,whichBins,leftTrial] =...
    extractSegmentTraces(dataCell,varargin)
%extractSegmentTraces.m Extracts traces for each segment and returns along
%with segment identity (left/right or white/black), net evidence (left -
%right or white - black) at that segment, and segment number
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%Optional inputs specified by two element name and value
%
%ranges - ranges of segments. Defaults to 0:80:480
%traceType - dFF or dGR
%
%OUTPUTS
%segTraces - nNeurons x (nTrials*nSeg) containing traces for each
%   segment
%segID - (nTrials*nSeg) x 1 array containing identity of each segment
%netEv - (nTrials*nSeg) x 1 array containing net evidence including the
%   current segment
%segNum - (nTrials*nSeg) x 1 array containing segment number
%numLeft - (nTrials*nSeg) x 1 array containing number of left segments
%runSpeed - (nTrials*nSeg) x 1 array containing time for each segment
%viewAngle - (nTrials*nSeg) x 1 array containing view angle for each segment
%whichBins - nSeg+1 x 1 cell array containing binIDs
%
%ASM 8/14

%initialize
segRanges = 0:80:480;
traceType = 'deconv';
segMeanRange = [0.5 1];
pcaThresh = 0.8;
useBins = false;
whichFactor = 2;
getDelay = false;
delayTraces = [];
outputTrials = false;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'segranges'
                segRanges = varargin{argInd+1};
            case 'tracetype'
                traceType = varargin{argInd+1};
            case 'segmeanrange'
                segMeanRange = varargin{argInd+1};
            case 'pcathresh'
                pcaThresh = varargin{argInd+1};
            case 'usebins'
                useBins = varargin{argInd+1};
            case 'whichfactor'
                whichFactor = varargin{argInd+1};
            case 'getdelay'
                getDelay = varargin{argInd+1};
            case 'outputtrials'
                outputTrials = varargin{argInd+1};
            otherwise
                error('Argument %s not recognized',varargin{argInd});
        end
    end
end

%ensure contains imaging data
if ~isfield(dataCell{1},'imaging') || sum(findTrials(dataCell,'imaging.imData == 1')) == 0
    error('dataCell must contain imaging data');
end

%eliminate non-imaging trials
dataCell = getTrials(dataCell,'imaging.imData==1');

% %bin if necessary
% if ~isfield(dataCell{1}.imaging,'binnedDFFTraces')
%     dataCell = binFramesByYPos(dataCell,binSize);
% end

%extract traces from dataCell
% if strcmpi(traceType,'dGR')
%     traces = catBinnedTraces(dataCell);
% elseif strcmpi(traceType,'dFF')
%     [~,traces] = catBinnedTraces(dataCell);
% else
%     error('Cannot process trace type');
% end

%get maze patterns
mazePatterns = getMazePatterns(dataCell);

%get net evidence
netEvidence = getNetEvidence(dataCell);

%get nSeg
nSeg = size(mazePatterns,2);

%get nTrials
nTrials = length(dataCell);

%get turn 
turn = getCellVals(dataCell,'result.leftTurn')';
leftTrial = getCellVals(dataCell,'maze.leftTrial')';

%initialize outputs
segTraces = [];
segId = mazePatterns(:);
netEv = netEvidence(:);
segNum = repmat(1:nSeg,nTrials,1);
segNum = segNum(:);
numLeft = repmat(sum(mazePatterns,2),nSeg,1);
turn = repmat(turn,nSeg,1);
leftTrial = repmat(leftTrial,nSeg,1);
runSpeed = zeros(size(segId));
runInd = 1;
viewAngle = nan(size(segNum));
viewInd = 1;
whichBins = cell(nSeg+1,1);

if useBins
    %get yPosBins
    yPosBins = dataCell{1}.imaging.yPosBins;
end

%loop through each segment and get traces
for segInd = 1:nSeg
    
    %loop through each trial to get the traces which correspond
    for trialInd = 1:length(dataCell)
        
        if useBins
            %find range which corresponds to segment
            segIndicesToUse = yPosBins >= segRanges(segInd) & yPosBins < segRanges(segInd+1);
            if isempty(whichBins{segInd})
                whichBins{segInd} = find(segIndicesToUse);
            end
            
            %get traces
%             traces = getTraces(dataCell,traceType,segIndicesToUse,trialInd,whichFactor,pcaThresh);
            traces = getBinnedTraces(dataCell,traceType,segIndicesToUse,trialInd,whichFactor,pcaThresh);
            
            %concatenate temporary traces
            segTraces = cat(3,segTraces,traces);
        else
            %find range which corresponds to segment
            segIndicesToUse = dataCell{trialInd}.imaging.dataFrames{1}(3,:) >= segRanges(segInd) &...
                dataCell{trialInd}.imaging.dataFrames{1}(3,:) < segRanges(segInd+1);
            
            %get traces
            traces = getTraces(dataCell,traceType,segIndicesToUse,trialInd,whichFactor,pcaThresh);
            
            %get time of segment
            tempTime = dataCell{trialInd}.imaging.dataFrames{1}(1,find(segIndicesToUse,1,'last')) - ...
                dataCell{trialInd}.imaging.dataFrames{1}(1,find(segIndicesToUse,1,'first'));
            runSpeed(runInd) = dnum2secs(tempTime);
            runInd = runInd + 1;
            
            %determine range to take mean over
            nFrames = size(traces,2);
            frameRange = round(segMeanRange*nFrames);
            
            %take mean
            meanTraces = mean(traces(:,frameRange(1):frameRange(2)),2);
            
            %concatenate
            segTraces = cat(2,segTraces,meanTraces);
        end
        
        %grab view angle
        viewAngle(viewInd) = rad2deg(nanmean(dataCell{trialInd}.imaging.dataFrames{1}(4,segIndicesToUse)));
        viewInd = viewInd + 1;
    end
    
end


%get delay if necessary
if getDelay
    
    nTrials = length(dataCell);
    
    %cat info on
    segNum = cat(1,segNum,nan(nTrials,1));
    segId = cat(1,segId,nan(nTrials,1));
    netEv = cat(1,netEv,netEvidence(:,nSeg));    
    
    %loop through each trial to get the traces which correspond
    for trialInd = 1:nTrials
        
        if useBins
            %find range which corresponds to segment
            segIndicesToUse = yPosBins >= segRanges(end);
            whichBins{nSeg+1} = find(segIndicesToUse);
            
            %get traces
%             traces = getTraces(dataCell,traceType,segIndicesToUse,trialInd,whichFactor,pcaThresh);
            traces = getBinnedTraces(dataCell,traceType,segIndicesToUse,trialInd,whichFactor,pcaThresh);
            
            %cat
            delayTraces = cat(3,delayTraces,traces);
        else
            %find range which corresponds to segment
            segIndicesToUse = dataCell{trialInd}.imaging.dataFrames{1}(3,:) >= segRanges(segInd);
            
            %get traces
            traces = getTraces(dataCell,traceType,segIndicesToUse,trialInd,whichFactor,pcaThresh);
            
            %get time of segment
            tempTime = dataCell{trialInd}.imaging.dataFrames{1}(1,find(segIndicesToUse,1,'last')) - ...
                dataCell{trialInd}.imaging.dataFrames{1}(1,find(segIndicesToUse,1,'first'));
            runSpeed(runInd) = dnum2secs(tempTime);
            runInd = runInd + 1;
            
            %determine range to take mean over
            nFrames = size(traces,2);
            frameRange = round(segMeanRange*nFrames);
            
            %take mean
            meanTraces = mean(traces(:,frameRange(1):frameRange(2)),2);
            
            %concatenate
            segTraces = cat(2,segTraces,meanTraces);
        end
    end
    
    
end

%convert to trial structure if necessary
if outputTrials
    %get nNeurons 
    nNeurons = size(segTraces,1);
    if useBins
        nBins = size(traces,2);
        segTraces = reshape(segTraces,nNeurons,nBins,nTrials,nSeg);
        segTraces = permute(segTraces,[1 2 4 3]);
    else
        segTraces = reshape(segTraces,nNeurons,nTrials,nSeg);
        segTraces = permute(segTraces, [1 3 2]);
    end
    
    segId = mazePatterns;
    netEv = netEvidence;
    segNum = repmat([1:6],nTrials,1);
    numLeft = cumsum(mazePatterns,2);
    runSpeed = reshape(runSpeed,nTrials,nSeg)';
    turn = reshape(turn,nTrials,nSeg);
    leftTrial = reshape(leftTrial,nTrials,nSeg);
    viewAngle = reshape(viewAngle,nTrials,nSeg);
    
end
    

end

function traces = getTraces(dataCell,traceType,segIndicesToUse,trialInd,whichFactor,pcaThresh)

%extract traces
switch lower(traceType)
    case 'dgr'
        traces = dataCell{trialInd}.imaging.dGRTraces{1}(:,segIndicesToUse);
    case 'dff'
        traces = dataCell{trialInd}.imaging.dFFTraces{1}(:,segIndicesToUse);
    case 'deconv'
        traces = dataCell{trialInd}.imaging.deconvTrace{1}(:,segIndicesToUse);
    case 'dffpca'
        traces = dataCell{trialInd}.imaging.dFFPCA{1}(1:find(dataCell{1}.imaging.dFFPCA{1}>pcaThresh,1,'first'),segIndicesToUse);
    case 'dgrpca'
        traces = dataCell{trialInd}.imaging.dGRPCA{1}(1:find(dataCell{1}.imaging.dGRPCA{1}>pcaThresh,1,'first'),segIndicesToUse);
    case 'dfffactor'
        traces = dataCell{trialInd}.imaging.projDFF{whichFactor}(:,segIndicesToUse);
    case 'dgrfactor'
        traces = dataCell{trialInd}.imaging.projDGR{1}{whichFactor}(:,segIndicesToUse);
    case 'behavior'
        traces = dataCell{trialInd}.imaging.dataFrames{1}(2:6,segIndicesToUse);
    otherwise
        error('Cannot process trace type');
end
end

function traces = getBinnedTraces(dataCell,traceType,segIndicesToUse,trialInd,whichFactor,pcaThresh)

%extract traces
switch lower(traceType)
    case 'dgr'
        traces = dataCell{trialInd}.imaging.dGRTraces{1}(:,segIndicesToUse);
    case 'dff'
        traces = dataCell{trialInd}.imaging.binnedDFFTraces{1}(:,segIndicesToUse);
    case 'deconv'
        traces = dataCell{trialInd}.imaging.binnedDeconvTraces{1}(:,segIndicesToUse);
    case 'dffpca'
        traces = dataCell{trialInd}.imaging.dFFPCA{1}(1:find(dataCell{1}.imaging.dFFPCA{1}>pcaThresh,1,'first'),segIndicesToUse);
    case 'dgrpca'
        traces = dataCell{trialInd}.imaging.dGRPCA{1}(1:find(dataCell{1}.imaging.dGRPCA{1}>pcaThresh,1,'first'),segIndicesToUse);
    case 'dfffactor'
        traces = dataCell{trialInd}.imaging.projDFF{whichFactor}(:,segIndicesToUse);
    case 'dgrfactor'
        traces = dataCell{trialInd}.imaging.projDGR{1}{whichFactor}(:,segIndicesToUse);
    case 'behavior'
        traces = dataCell{trialInd}.imaging.binnedDataFrames(3,segIndicesToUse);
    otherwise
        error('Cannot process trace type');
end
end