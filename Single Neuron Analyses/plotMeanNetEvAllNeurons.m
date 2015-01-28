function plotMeanNetEvAllNeurons(dataCell,varargin)
%plotMeanNetEvAllNeurons.m Plots the mean of all neurons for every net
%evidence possibility at each segment
%
%INPUTS
%dataCell - dataCell containing imaging and integration info
%
%ASM 10/14

traceType = 'dff';
range = [0.5 0.75];
takeMeanBin = false;
plotHeatMap = true;
segRanges = 0:80:480;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'tracetype'
                traceType = varargin{argInd+1};
            case 'range'
                range = varargin{argInd+1};
            case 'takemeanbin'
                takeMeanBin = varargin{argInd+1};
            case 'plotheatmap'
                plotHeatMap = varargin{argInd+1};
            case 'segranges'
                segRanges = varargin{argInd+1};
        end
    end
end

%extract segment traces
[segTraces,~,netEv,segNum,~,~,delayTraces] = extractSegmentTraces(dataCell,'usebins',true,...
    'tracetype',traceType,'getDelay',true);

%get nNeurons
[nNeurons,nBinsPerSeg,~] = size(segTraces);

%take mean of each segment trace across range
if takeMeanBin
    meanBinRange = round(range*nBinsPerSeg);
    segTraces = mean(segTraces(:,meanBinRange(1):meanBinRange(2),:),2);
    nBinsPerSeg = 1;
end

%get nSeg
nSeg = length(unique(segNum(~isnan(segNum))));

%get unique net evidence conditions
uniqueNetEv = unique(netEv);
nNetEv = length(uniqueNetEv);
uniqueNetEvSeg = cell(1,nSeg+1);

%get number of bins
nBins = nBinsPerSeg*nSeg;

%process delay info
nBins = nBins + size(delayTraces,2);
segToLoop = nSeg+1;

%initialize
actNetEv = nan(nNetEv,nBins,nNeurons);

for segInd = 1:segToLoop
    
    %set binsToLoop
    if segInd <= nSeg
        binsToLoop = nBinsPerSeg;
    else
        binsToLoop = size(delayTraces,2);
    end
    
    %get traces which match
    if segInd > nSeg
        segTracesSub = delayTraces;
        netEvSub = netEv(isnan(segNum));
    else
        segTracesSub = segTraces(:,:,segNum==segInd);
        netEvSub = netEv(segNum==segInd);
    end
    
    %get uniqueNetEvSeg
    uniqueNetEvSeg{segInd} = unique(netEvSub);
    
    
    %loop through each net ev condition
    for condInd = 1:nNetEv
        
        %loop through each bin
        for binInd = 1:binsToLoop
            
            %get subset containing only trials with that net ev condition
            traceSub = segTracesSub(:,binInd,netEvSub == uniqueNetEv(condInd));
            
            %take mean for each neuron and store
            actNetEv(condInd,(segInd-1)*nBinsPerSeg + binInd,:) = nanmean(traceSub,3);
        end
        
    end
    
end

%%%%%%determine left/right selective neurons

%divide into left and right trials
leftTrials = getTrials(dataCell,'maze.leftTrial==1');
rightTrials = getTrials(dataCell,'maze.leftTrial==0');

%get left and right traces
[~,leftTraces] = catBinnedTraces(leftTrials);
[~,rightTraces] = catBinnedTraces(rightTrials);

%reshape into nNeurons x (nBins*nTrials)
leftTraces = reshape(leftTraces,nNeurons,[]);
rightTraces = reshape(rightTraces,nNeurons,[]);

%take mean for each neuron
leftMean = mean(leftTraces,2);
rightMean = mean(rightTraces,2);

%get selectivity
selectivity = (leftMean - rightMean)./(leftMean + rightMean);

%get left neurons
leftNeurons = selectivity>0;
rightNeurons = selectivity<0;

%%% get plots

%take mean across all neurons
allNeuronMean = nanmean(actNetEv,3);

%take mean across left/right neurons
leftNeuronMean = nanmean(actNetEv(:,:,leftNeurons),3);
rightNeuronMean = nanmean(actNetEv(:,:,rightNeurons),3);


%get binsToPlot
binsToPlot = dataCell{1}.imaging.yPosBins(end-nBins+1:end);
binOffset = 0.5*mean(diff(binsToPlot));

if plotHeatMap
    %plot each
    figure;
    
    subplot(2,2,1:2);
    imagescnan(binsToPlot,uniqueNetEv,allNeuronMean);
    title('All Neurons');
    %add segment lines
    for segInd = 0:nSeg
        line(repmat(segRanges(segInd+1)-binOffset,1,2),[-nSeg*2 nSeg*2],...
            'Color','k','LineStyle','--');
    end
    colorbar;
    
    
    subplot(2,2,3);
    imagescnan(binsToPlot,uniqueNetEv,leftNeuronMean);
    title('Left-Preferring Neurons');
    %add segment lines
    for segInd = 0:nSeg
        line(repmat(segRanges(segInd+1)-binOffset,1,2),[-nSeg*2 nSeg*2],...
            'Color','k','LineStyle','--');
    end
    colorbar;
    
    subplot(2,2,4);
    imagescnan(binsToPlot,uniqueNetEv,rightNeuronMean);
    title('Right-Preferring Neurons');
    %add segment lines
    for segInd = 0:nSeg
        line(repmat(segRanges(segInd+1)-binOffset,1,2),[-nSeg*2 nSeg*2],...
            'Color','k','LineStyle','--');
    end
    colorbar;
    
    suplabel('Y Position','x');
    suplabel('Net Evidence','y');
else
    %create figure
    figure;
    
    %plot all neurons
    subplot(3,1,1);
    plotMeanNetEvLine(allNeuronMean,nNetEv,nSeg,nBinsPerSeg,binsToPlot,...
        uniqueNetEvSeg,uniqueNetEv,segRanges);
    title('All Neurons');
    
    %plot left neurons
    subplot(3,1,2);
    plotMeanNetEvLine(leftNeuronMean,nNetEv,nSeg,nBinsPerSeg,binsToPlot,...
        uniqueNetEvSeg,uniqueNetEv,segRanges);
    title('Left Neurons');
    
    %plot all neurons
    subplot(3,1,3);
    plotMeanNetEvLine(rightNeuronMean,nNetEv,nSeg,nBinsPerSeg,binsToPlot,...
        uniqueNetEvSeg,uniqueNetEv,segRanges);
    title('Right Neurons');
    
    %label
    suplabel('Activity','y');
    suplabel('Y Position','x');
    
    %create colorbar
    colorbar;
    colormap(jet);
    caxis([-nSeg nSeg]);
    
end

end

function plotMeanNetEvLine(neuronMean,nNetEv,nSeg,nBinsPerSeg,binsToPlot,...
    uniqueNetEvSeg,uniqueNetEv,segRanges)

axH = gca;

%create colormap
colors = jet(nNetEv+1);
hold on;

%loop through each segment and plot lines
for segInd = 1:(nSeg+1)
    
    if segInd <= nSeg
        xRange = 1+(segInd-1)*nBinsPerSeg:nBinsPerSeg*segInd;
    else
        xRange = 1+(segInd-1)*nBinsPerSeg:length(binsToPlot);
    end
    
    %loop through each segcond
    for condInd = 1:length(uniqueNetEvSeg{segInd})
        tempPlot = plot(binsToPlot(xRange),...
            neuronMean(ismember(uniqueNetEv,uniqueNetEvSeg{segInd}(condInd)),...
            xRange));
        tempPlot.Color = colors(ismember(uniqueNetEv,uniqueNetEvSeg{segInd}(condInd)),:);
        tempPlot.LineWidth = 2;
    end
end

%add segment lines
for segInd = 0:nSeg
    line(repmat(segRanges(segInd+1),1,2),axH.YLim,...
        'Color','k','LineStyle','--');
end

%set xlim
axH.XLim = [min(binsToPlot) max(binsToPlot)];
end

