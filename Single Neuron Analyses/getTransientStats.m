function stats = getTransientStats(dataCell,varargin)
%getTransientStats.m Calculates various statistics about the transients,
%including duration (in sec), duration (as function of total trial time),
%number of transients per trial
%
%INPUTS
%dataCell - dataCell containing imaging data
%varargin - various arguments input as pairs
%   shouldSmooth - should smooth neuronal data
%   smoothLength - if smooth, length of smooth filter
%
%OUTPUTS
%stats - stats structure containing outputs
%
%
%ASM 10/14

shouldSmooth = true;
smoothLength = 3;
traceType = 'dFF';
segRange = [0 480];
limitToSeg = false;
ignoreSilent = true;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'shouldsmooth'
                shouldSmooth = varargin{argInd+1};
            case 'smoothlength'
                smoothLength = varargin{argInd+1};
            case 'tracetype'
                traceType = varargin{argInd+1};
            case 'segrange' 
                segRange = varargin{argInd+1};
            case 'limittoseg'
                limitToSeg = varargin{argInd+1};
            case 'ignoresilent'
                ignoreSilent = varargin{argInd+1};
        end
    end
end

%get nTrials
nTrials = length(dataCell);

%get nNeurons
nNeurons = size(dataCell{1}.imaging.dFFTraces{1},1);

%initialize outputs
nTransients = zeros(nNeurons,nTrials);
transientLength = cell(nNeurons,nTrials);
trialLength = zeros(1,nTrials);

%loop through each trial
for trialInd = 1:nTrials
    
    %get temp trace
    switch upper(traceType)
        case 'DFF'
            tempTrace = dataCell{trialInd}.imaging.dFFTraces{1};
        case 'DGR'
            tempTrace = dataCell{trialInd}.imaging.dGRTraces{1};
    end
    
    %smooth each neuron
    if shouldSmooth
        tempTrace = arrayfun(@(x) smooth(tempTrace(x,:),smoothLength)',1:nNeurons,'UniformOutput',false);
        tempTrace = cat(1,tempTrace{:});
    end
    
    %take only segment part
    if limitToSeg
        
        %find bins within range
        binInd = dataCell{trialInd}.imaging.dataFrames{1}(3,:) >= segRange(1) &...
            dataCell{trialInd}.imaging.dataFrames{1}(3,:) < segRange(2);
        
        %limit to binInd
        tempTrace = tempTrace(:,binInd);
    end
        
    
    %loop through each neuron and find statistics
    for neuronInd = 1:nNeurons
    
        %find transients
        [start,stop] = findContinuousRegions(tempTrace(neuronInd,:));
        
        %get transient length in time
        tempLengths = dataCell{trialInd}.imaging.dataFrames{1}(1,stop) - ...
            dataCell{trialInd}.imaging.dataFrames{1}(1,start);
        tempLengths = dnum2secs(tempLengths);
        
        %get nTransients
        nTransients(neuronInd,trialInd) = length(start);
        
        %store 
        transientLength{neuronInd,trialInd} = tempLengths;
        
        %if ignore silent
        if ignoreSilent && nTransients(neuronInd,trialInd) == 0 
            nTransients(neuronInd,trialInd) = NaN;
            transientLength{neuronInd,trialInd} = NaN;
        end

    end
    
    dispProgress('Calculating statistics: trial %d/%d',trialInd,trialInd,nTrials);
    
    %get trialLength
    if limitToSeg
        trialLength(trialInd) = dnum2secs(dataCell{trialInd}.imaging.dataFrames{1}(1,...
            find(binInd,1,'last')) - ...
            dataCell{trialInd}.imaging.dataFrames{1}(1,find(binInd,1,'first')));
    else
        trialLength(trialInd) = dnum2secs(dataCell{trialInd}.imaging.dataFrames{1}(1,end) - ...
            dataCell{trialInd}.imaging.dataFrames{1}(1,1));
    end
        
    
end

%concatenate all transients form all trials from a given neuron
allTransients = arrayfun(@(x) cat(2,transientLength{x,:}),1:nNeurons,'UniformOutput',false);

%calculate transientLength as fraction of trial time
fracLength = cell(nNeurons,1);
for neuronInd = 1:nNeurons
    tempNeuron = cellfun(@(x,y) x/y,transientLength(neuronInd,:),num2cell(trialLength),'UniformOutput',false);
    fracLength{neuronInd} = cat(2,tempNeuron{:});
end

%store in stats
stats.nTransientsAll = nTransients;
stats.meanNTransients = nanmean(nTransients,2);
stats.stdNTransients = nanstd(nTransients,0,2);
stats.transientLengths = transientLength;
stats.allTransients = allTransients;
stats.fracLength = fracLength;
stats.meanTransLength = cellfun(@nanmean,allTransients);
stats.stdTransLEngth = cellfun(@nanstd,allTransients);
stats.meanFracLength = cellfun(@nanmean,fracLength);
stats.stdFracLength = cellfun(@nanstd,fracLength);