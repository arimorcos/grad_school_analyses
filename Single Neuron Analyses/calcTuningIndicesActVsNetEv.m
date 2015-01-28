function [tuning] = calcTuningIndicesActVsNetEv(dataCell,varargin)
%calcTuningIndicesActVsNetEv.m Function to calculate tuning indices for
%individual cells of activity vs. net evidence
%
%INPUTS
%dataCell - dataCell with imaging and integration data
%
%OUTPUTS
%tuning - nCells x 1 or nCells x nSeg array of tuning indices
%
%ASM 10/14

traceType = 'dff';
sepSeg = false;
range = [0.5 0.75];
shouldPlot = true;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'tracetype'
                traceType = varargin{argInd+1};
            case 'sepseg'
                sepSeg = varargin{argInd+1};
            case 'range'
                range = varargin{argInd+1};
            case 'shouldplot'
                shouldPlot = varargin{argInd+1};
        end
    end
end

%extract segment traces
[segTraces,~,netEv,segNum,~,~] = extractSegmentTraces(dataCell,'usebins',true,...
    'tracetype',traceType);

%get nNeurons
[nNeurons,nBinsPerSeg,~] = size(segTraces);

%take mean of each segment trace across range
meanBinRange = round(range*nBinsPerSeg);
segTraces = mean(segTraces(:,meanBinRange(1):meanBinRange(2),:),2);

%get unique net evidence conditions
uniqueNetEv = unique(netEv);
nNetEv = length(uniqueNetEv);

%get nSeg
nSeg = length(unique(segNum));

if sepSeg %if treating each segment individually
    
    %initialize
    actNetEv = cell(1,nSeg);
    uniqueNetEvSeg = cell(1,nSeg);
    tuning = zeros(nNeurons,nSeg);
    
    for segInd = 1:nSeg
        
        %get traces which match
        segTracesSub = segTraces(:,:,segNum==segInd);
        netEvSub = netEv(segNum==segInd);
        
        %get unique net evidence conditions
        uniqueNetEvSeg{segInd} = unique(netEvSub);
        nNetEvSeg = length(uniqueNetEvSeg{segInd});
        
        %initialize
        actNetEv{segInd} = zeros(nNetEvSeg,nNeurons);
        
        %loop through each net ev condition
        for condInd = 1:nNetEvSeg
            
            %get subset containing only trials with that net ev condition
            traceSub = segTracesSub(:,:,netEvSub == uniqueNetEvSeg{segInd}(condInd));
            
            %take mean for each neuron and store
            actNetEv{segInd}(condInd,:) = nanmean(traceSub,3)';
            
        end
        
        %%%%%%calculate tuning index for each cell
        
        %loop through each neuron
        for neuronInd = 1:nNeurons
            
            %set to 0 if no active values
            if ~any(actNetEv{segInd}(:,neuronInd))
                tuning(neuronInd,1) = 0;
                continue;
            end
            
            %find preferred direction and get preferred value
            [prefVal,prefInd] = max(actNetEv{segInd}(:,neuronInd));
            
            %get indices of nonpreferred values
            nonPrefInd = setdiff(1:nNetEvSeg,prefInd);
            
            %get mean of values
            nonPrefMeanVal = nanmean(actNetEv{segInd}(nonPrefInd,neuronInd));
            
            %calculate tuning
            tuning(neuronInd,segInd) = (prefVal - nonPrefMeanVal)/(prefVal+nonPrefMeanVal);
        end
        
    end
    
else %if grouping all segments together
    
    %initialize
    actNetEv = zeros(nNetEv,nNeurons);
    
    %loop through each net ev condition
    for condInd = 1:nNetEv
        
        %get subset containing only trials with that net ev condition
        traceSub = segTraces(:,:,netEv == uniqueNetEv(condInd));
        
        %take mean for each neuron and store
        actNetEv(condInd,:) = nanmean(traceSub,3)';
        
    end
    
    
    %%%%%%calculate tuning index for each cell
    
    tuning = zeros(nNeurons,1);
    %loop through each neuron
    for neuronInd = 1:nNeurons
        
        %set to 0 if no active values
        if ~any(actNetEv(:,neuronInd))
            tuning(neuronInd,1) = 0;
            continue;
        end
        
        %find preferred direction and get preferred value
        [prefVal,prefInd] = max(actNetEv(:,neuronInd));
        
        %get indices of nonpreferred values
        nonPrefInd = setdiff(1:nNetEv,prefInd);
        
        %get mean of values
        nonPrefMeanVal = nanmean(actNetEv(nonPrefInd,neuronInd));
        
        %calculate tuning
        tuning(neuronInd,1) = (prefVal - nonPrefMeanVal)/(prefVal+nonPrefMeanVal);
    end
end

%plot
if shouldPlot
    if sepSeg %if multiple segments
        figure;
        for segInd = 1:nSeg
            subplot(4,2,segInd);
            histogram(tuning(:,segInd),10);
            title(sprintf('Segment #%d',segInd));
            set(gca,'FontSize',20);
            xlim([0 1]);
        end
        
        subplot(4,2,7:8);
        meanValPlot = plot(mean(tuning));
        meanValPlot.LineWidth = 2;
        meanValPlot.Parent.YLabel.String = 'Tuning Index';
        meanValPlot.Parent.XLabel.String = 'Segment';
    else
        figure;
        histogram(tuning,10);
        title('Tuning Index Distribution','FontSize',30);
        xlabel('Tuning Index','FontSize',30);
        ylabel('Count','FontSize',30);
        set(gca,'FontSize',20);
        xlim([0 1]);
    end
    
    
    
end