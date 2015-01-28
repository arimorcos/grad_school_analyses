%%%%%%%%%%%%%%%%%%%%% SET PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
noiseFac = 10; %noise scale fac - larger means more noise
activityFac = 150; %activity scale fac 
activeFrac = 1; %fraction of neurons which are active
selectivityOffset = 1.5; %offset for selectivity 0 represents normal distribution centered at no selectivity, 1 represents normal distribution centered at total selectivity
maxTimeFac = 0.2; %fraction of neurons which are time selective
nNeurons = 150; %number of neurons
nBins = 100; %number of position bins
segStarts = [1 11 21 31 41 51]; %bins where segments start
nSeg = length(segStarts);
segEnds = segStarts + 9;
parabFac = -activityFac/100;

%%%%%%%%%%%%%% CREATE DATASET %%%%%%%%%%%%%%%%%%%%%%
%get nTrials
nTrials = length(dataCell);

%initialize array
neuronArray = zeros(nNeurons,nBins,nTrials);

%add noise to data
neuronArray = neuronArray + noiseFac*randn(nNeurons,nBins,nTrials);

%determine which neurons are active
activeNeurons = sort(randperm(150,round(activeFrac*150)));

%determine which neurons are selective 
neuronSelectivity = zeros(nNeurons,1);
neuronSelectivity(activeNeurons) = randn(length(activeNeurons),1)+selectivityOffset;
neuronSelectivity = max(neuronSelectivity,0);
neuronSelectivity = min(neuronSelectivity,1);

%determine which neruons are time selective 
timeSelectivity = zeros(nNeurons,1);
timeSelectivity(activeNeurons) = randi([10 maxTimeFac*1000],length(activeNeurons),1)/1000;

%determine time of activity
activeTime = randi([1 nBins],nNeurons,1);

%generate neuron activity scaleFac
neuronActivity = zeros(nNeurons,1);
neuronActivity(activeNeurons) = rand(length(activeNeurons),1);

%generate neuron netEv pref
netEvPref = randi([-6 6],nNeurons,1);

%generate neuron turn pref
turnPref = netEvPref;
turnPref(turnPref == 0) = randsample([-1 1],sum(turnPref==0),1);
turnPref(turnPref < 0) = 0;
turnPref(turnPref > 1) = 1;

%get maze patterns
allMazePatterns = getMazePatterns(dataCell);
allMazePatterns(allMazePatterns == 0) = -1;

%loop thorugh each trial
for trialInd = 1:nTrials 
    
    %get trial info
    leftTrial = dataCell{trialInd}.maze.leftTrial;
    numLeft = dataCell{trialInd}.maze.numLeft;
    mazePattern = allMazePatterns(trialInd,:);
    
    %loop through each neuron and generate activity
    for neuronInd = 1:nNeurons %for each neuron
        
        %if not active, continue
        if ~ismember(neuronInd,activeNeurons)
            continue;
        end
        
        %get segment number of current neuron preferred firing time
        currSeg = find(segStarts < activeTime(neuronInd),1,'last');
        if activeTime(neuronInd) > max(segEnds); currSeg = NaN; end %set to nan if in delay
        
        %find scaleFac 
        if ~isnan(currSeg) %if in segments
            
            %CURRENTLY CARES ABOUT TURN EVEN IN ACCUMULATION PHASE --
            %SHOULDN'T
            
            %get cumulative evidendce
            cumEv = sum(mazePattern(1:currSeg));
            
            %set std
            tempSTD = (nSeg/2)*(1 - neuronSelectivity(neuronInd)); %more selective, smaller the std
            
            %get trialScaleFac
            trialScaleFac = (1/(tempSTD*sqrt(2*pi)))*exp(-((cumEv-netEvPref(neuronInd)).^2)/(2*tempSTD^2));
            
            %get max possible value
            possVal = (1/(tempSTD*sqrt(2*pi)))*exp(-(((-nSeg:nSeg)-netEvPref(neuronInd)).^2)/(2*tempSTD^2));
            
            %normalize
            normVals = mat2gray([trialScaleFac possVal]);
            
            %extract normalized value
            trialScaleFac = normVals(1);
            
        else %if is in delay
            
            %find out if turn matches 
            if leftTrial == turnPref(neuronInd)
                trialScaleFac = 1;
            else
                trialScaleFac = 1 - neuronSelectivity(neuronInd);
            end
        end
        
        %find bins where neuron should be active
        halfBinWidth = round(timeSelectivity(neuronInd)*nBins); 
        binRange = activeTime(neuronInd) - halfBinWidth:activeTime(neuronInd) + halfBinWidth;
        binRange(binRange <= 0) = [];
        binRange(binRange > nBins) = [];
        if ~isnan(currSeg)
            binRange(binRange > segEnds(currSeg)) = []; %cut off data after segment ends
            binRange(binRange < segStarts(currSeg)) = []; %cut off data before segment begins
        end
        lengthActive = length(binRange);
        
        %determine peak activity
        peakActivity = trialScaleFac*activityFac*neuronActivity(neuronInd);
        
        %generate curve
        activityCurve = (1/(halfBinWidth*sqrt(2*pi)))*exp(-((binRange-activeTime(neuronInd)).^2)/(2*halfBinWidth^2));
%         activityCurve = parabFac*(binRange-activeTime(neuronInd)).^2 + peakActivity;
        activityCurve = peakActivity*mat2gray(activityCurve);
        
        %store
        neuronArray(neuronInd,binRange,trialInd) = activityCurve + neuronArray(neuronInd,binRange,trialInd);
        
    end
    
    dataCell{trialInd}.imaging.binnedDFFTraces = {neuronArray(:,:,trialInd)};
    dataCell{trialInd}.imaging.binnedDGRTraces = {neuronArray(:,:,trialInd)};
    dataCell{trialInd}.imaging.binnedPCATraces = {neuronArray(:,:,trialInd)};
    dataCell{trialInd}.imaging.dGRVarAccounted = linspace(0,1,nNeurons);
    dataCell{trialInd}.imaging.imData = 1;
    dataCell{trialInd}.imaging.yPosBins = 1:nBins;
    
end
dataCell{1}.imaging.completeDFFTrace = zeros(1,10000);

        
