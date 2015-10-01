function figH = plotDFFVsNetEv(dataCell,varargin)
%plotDFFVsNetEv.m Plots mean dF/F for each net evidence condition for each
%neuron in the dataset
%
%INPUTS
%dataCell - dataCell containing imaging and integration data
%
%OUTPUTS
%figH - figure handle
%
%ASM 10/14

traceType = 'dff';
sepSeg = false;
range = [0.5 0.75];
nCellsToPlot = 5;
cellID = [];
shouldNorm = false;
shouldVis = 'on';
figH = [];
axH = [];

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
            case 'ncellstoplot'
                nCellsToPlot = varargin{argInd+1};
            case 'cellid'
                cellID = varargin{argInd+1};
            case 'shouldnorm'
                shouldNorm = varargin{argInd+1};
            case 'shouldvis'
                shouldVis = varargin{argInd+1};
            case 'figh'
                figH = varargin{argInd+1};
            case 'axh' 
                axH = varargin{argInd+1};
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
    
    %generate cells to plot
    if isempty(cellID)
        cellsToPlot = randperm(nNeurons,nCellsToPlot);
    else
        cellsToPlot = cellID;
    end
    
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
        
        %normalize
        if shouldNorm
            actNetEv{segInd} = bsxfun(@rdivide,actNetEv{segInd},max(actNetEv{segInd}));
            yLabStr = 'Normalized Activity';
        else
            yLabStr = 'Activity';
        end
        
        %calculate tuning index
        
        
    end
    
    %plot
    figH = figure('visible',shouldVis);
    for segInd = 1:nSeg
        subplot(3,2,segInd);
        plot(uniqueNetEvSeg{segInd},actNetEv{segInd}(:,cellsToPlot),'LineWidth',2);
        title(sprintf('Segment #%d',segInd));
        set(gca,'FontSize',20);
    end
    suplabel('Net Evidence','x');
    suplabel(yLabStr,'y');
    
else %if grouping all segments together
    
    %initialize
    actNetEv = zeros(nNetEv,nNeurons);
    actNetEvErr = zeros(nNetEv,nNeurons);
    
    %loop through each net ev condition
    for condInd = 1:nNetEv
        
        %get subset containing only trials with that net ev condition
        traceSub = segTraces(:,:,netEv == uniqueNetEv(condInd));
        
        %take mean for each neuron and store
        actNetEv(condInd,:) = nanmean(traceSub,3)';
        tempSTD = std(traceSub,0,3)';
        tempSTD = tempSTD/sqrt(size(traceSub,3));
        actNetEvErr(condInd,:) = tempSTD;
        
    end
    
    %normalize
    if shouldNorm
        actNetEv = bsxfun(@rdivide,actNetEv,max(actNetEv));
        yLabStr = 'Normalized Activity';
    else
        yLabStr = 'Activity';
    end
    
    %generate cells to plot
    if isempty(cellID)
        cellsToPlot = randperm(nNeurons,nCellsToPlot);
    else
        cellsToPlot = cellID;
    end
    
    %plot
    if isempty(figH)
        figH = figure('Visible',shouldVis);
    end
    if isempty(axH)
        axH = axes;
    else
        axes(axH);
    end
    cellPlot=errorbar(uniqueNetEv,actNetEv(:,cellsToPlot),actNetEvErr(:,cellsToPlot));
    cellPlot.LineWidth = 2;
    set(axH,'FontSize',20);
    xlabel('Net Evidence','FontSize',30);
    ylabel(yLabStr,'FontSize',30);
    xlim([-nSeg nSeg]);
    beautifyPlot(figH,axH);
    axH.XTickLabel = {'6R','4R','2R','0','2L','4L','6L'};
    
end



