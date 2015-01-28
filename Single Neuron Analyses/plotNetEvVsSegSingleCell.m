function figH = plotNetEvVsSegSingleCell(dataCell,varargin)
%plotNetEvVsSegSingleCell.m Plots mean dF/F for each net evidence condition for each
%segment in the dataset
%
%INPUTS
%dataCell - dataCell containing imaging and integration data
%cellID - cell to plot
%
%OUTPUTS
%figH - figure handle
%
%ASM 10/14

traceType = 'dff';
takeMeanBin = false;
range = [0.5 0.75];
shouldVis = 'on';
getDelay = false;
cellID = 1;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'tracetype'
                traceType = varargin{argInd+1};
            case 'takemeanbin'
                takeMeanBin = varargin{argInd+1};
            case 'range'
                range = varargin{argInd+1};
            case 'shouldvis'
                shouldVis = varargin{argInd+1};
            case 'getdelay'
                getDelay = varargin{argInd+1};
            case 'cellid'
                cellID = varargin{argInd+1};
        end
    end
end

%get nTrials
nTrials = length(dataCell);

%extract segment traces
[segTraces,~,netEv,segNum,~,~,delayTraces] = extractSegmentTraces(dataCell,'usebins',true,...
    'tracetype',traceType,'getDelay',getDelay);

%subset to neuron to plot
segTraces = segTraces(cellID,:,:);

%get nNeurons
[~,nBinsPerSeg,~] = size(segTraces);

%take mean of each segment trace across range
if takeMeanBin
    meanBinRange = round(range*nBinsPerSeg);
    segTraces = mean(segTraces(:,meanBinRange(1):meanBinRange(2),:),2);
    nBinsPerSeg = 1;
end

%get unique net evidence conditions
uniqueNetEv = unique(netEv);
nNetEv = length(uniqueNetEv);

nSeg = length(unique(segNum(~isnan(segNum))));

%get number of bins
nBins = nBinsPerSeg*nSeg;

%check getDelay
if getDelay
    nBins = nBins + size(delayTraces,2);
    delayTraces = delayTraces(cellID,:,:);
    segToLoop = nSeg+1;
else
    segToLoop = nSeg;
end

%initialize
actNetEv = nan(nNetEv,nBins);

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

    
    %loop through each net ev condition
    for condInd = 1:nNetEv
        
        %loop through each bin
        for binInd = 1:binsToLoop
            
            %get subset containing only trials with that net ev condition
            traceSub = segTracesSub(:,binInd,netEvSub == uniqueNetEv(condInd));
            
            %take mean for each neuron and store
            actNetEv(condInd,(segInd-1)*nBinsPerSeg + binInd) = nanmean(traceSub,3);
        end
        
    end
    
end

%create figure
figH = figure('Visible',shouldVis);

%plot imagesc
imPlot = imagescnan(1:nBins,-nSeg:nSeg,actNetEv);
imPlot.Parent.XLabel.String = 'Bin #';
imPlot.Parent.XLabel.FontSize = 30;
imPlot.Parent.YLabel.String = 'Net Evidence';
imPlot.Parent.YLabel.FontSize = 30;
imPlot.Parent.FontSize = 20;

%add segment lines
for segInd = 0:nSeg
    line(repmat(nBinsPerSeg*(segInd)+0.5,1,2),[-nSeg*2 nSeg*2],...
        'Color','k','LineStyle','--');
end

%add colorbar
cBar = colorbar;
cBar.FontSize = 20;
cBar.Label.String = 'Thresholded dF/F';
cBar.Label.FontSize = 30;


x = 5;