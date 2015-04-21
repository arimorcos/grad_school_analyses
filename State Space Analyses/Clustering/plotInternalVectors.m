function plotInternalVectors(dataCell,varargin)
%plotInternalVectors.m Plots internal vector similarity vs.
%starting distance
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%
%
%OUTPUTS
%
%ASM 4/15

shouldShuffle = true;
nShuffles = 200;
shouldPlot = true;
startDistMetric = 'seuclidean';
vectorDistMetric = 'seuclidean';
pointLabels = {'Segment 1','Segment 2','Segment 3','Segment 4',...
    'Segment 5','Segment 6','Early Delay','Late Delay','Turn'};
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'shouldshuffle'
                shouldShuffle = varargin{argInd+1};
            case 'nshuffles'
                nShuffles = varargin{argInd+1};
            case 'startdistmetric'
                startDistMetric = varargin{argInd+1};
            case 'vectordidstmetric'
                vectorDistMetric = varargin{argInd+1};
            case 'shouldplot'
                shouldPlot = varargin{argInd+1};
        end
    end
end


%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%get tracs
[~,traces] = catBinnedTraces(dataCell);

%get nNeurons
nTrials = size(traces,3);

%get mazePatterns
mazePatterns = getMazePatterns(dataCell);
netEvidence = getNetEvidence(dataCell);
netEvidence = cat(2,zeros(nTrials,1),netEvidence);
nSeg = size(mazePatterns,2);

%%%%%%%%% Create matrix of values at each point in the maze

tracePoints = getMazePoints(traces,yPosBins);
% nPoints = nSeg + 1;
% tracePoints = tracePoints(:,1:nPoints,:);
nPoints = 9;


%%%%% Calculate distances
% take all trial pairs
allPairs = allcomb(1:nTrials,1:nTrials);
allPairs(allPairs(:,2) <= allPairs(:,1),:) = []; %crop out duplicates and same trial pairs

%initialize
internalStartDist = cell(nPoints,1);
internalVecDist = cell(nPoints,1);

%loop through each segment
for pointInd = 1:nPoints
    
    %get current net evidence
    if pointInd > nSeg
        currNetEv = netEvidence(:,nSeg);
    else
        currNetEv = netEvidence(:,pointInd);
    end
    
    %get cluster pairs with the same net evidence
    pairNetEv = [currNetEv(allPairs(:,1)) currNetEv(allPairs(:,2))];
    sameNetEv = pairNetEv(:,1) == pairNetEv(:,2);
    tempPairs = allPairs(sameNetEv,:);
    
    % calculate starting distance for all pairs
    allStartDists = squareform(pdist(squeeze(tracePoints(:,pointInd,:))',startDistMetric));
    
    %filter pairs for external and internal
    if pointInd > nSeg
        internalPairs = tempPairs;
    else
        internalPairs = tempPairs(mazePatterns(tempPairs(:,1),pointInd) == ...
            mazePatterns(tempPairs(:,2),pointInd),:); %keep pairs with the same marginal segments
    end
    
    %get indices to keep
    internalInd = sub2ind(size(allStartDists),internalPairs(:,1),internalPairs(:,2));
    
    %get indices and crop to relevant starting distances
    internalStartDist{pointInd} = allStartDists(internalInd);
    
    %get vectors
    trialVecs = squeeze(tracePoints(:,pointInd+1,:))' - squeeze(tracePoints(:,pointInd,:))';
    
    %get distances
    allVecDists = squareform(pdist(trialVecs,vectorDistMetric));
    
    %crop
    internalVecDist{pointInd} = allVecDists(internalInd);
    
    
end

%%% plot for each
if shouldPlot
    figH = figure;
    figH.Units = 'normalized';
    figH.OuterPosition = [0 0 1 1];
    [nRows, nCol] = calcNSubplotRows(nPoints);
    sameR2 = nan(nPoints,1);
    rup2 = nan(nPoints,1);
    rlo2 = nan(nPoints,1);
    sameP = nan(nPoints,1);
    for pointInd = 1:nPoints
        axH = subplot(nRows,nCol,pointInd);
        hold(axH,'on');
        
        % scatter
        scatInternal = scatter(internalStartDist{pointInd},internalVecDist{pointInd});
        
        %color
        scatInternal.MarkerEdgeColor = 'flat';
        
        %normalize
        allDist = cat(1,internalStartDist{pointInd},internalVecDist{pointInd});
        minVal = min(allDist);
        maxVal = max(allDist);
        axH.XLim = [minVal maxVal];
        axH.YLim = [minVal maxVal];
        
        %get fit
        xVals = linspace(min(axH.XLim),max(axH.XLim),20);
        mdl = fitlm(internalStartDist{pointInd},internalVecDist{pointInd});
        b = mdl.Coefficients{:,'Estimate'};
        fitH = plot(xVals, b(2)*xVals + b(1));
        fitH.LineStyle = '--';
        fitH.LineWidth = 2;
        fitH.Color = 'k';
        
        %get corrcoef
        [sameR,p,rlo,rup] = corrcoef(internalVecDist{pointInd},internalStartDist{pointInd});
        sameP(pointInd) = p(2,1);
        sameR2(pointInd) = sameR(2,1)^2;
        rlo2(pointInd) = rlo(2,1)^2;
        rup2(pointInd) = rup(2,1)^2;
        
        %add text
        maxY = max(axH.YLim);
        minX = min(axH.XLim);
        text(minX+0.05,maxY-0.01,sprintf('R^{2}: %.3f, p = %.1d',sameR2(pointInd),sameP(pointInd)),...
            'VerticalAlignment','Top','HorizontalAlignment','Left',...
            'FontWeight','Bold','FontSize',15);
        
        %labels
%         axH.YLabel.String = sprintf('Vector distances (%s)',vectorDistMetric);
%         axH.XLabel.String = sprintf('Start Distance (%s)',startDistMetric);
        axH.Title.String = pointLabels{pointInd};
        axis(axH,'square');
        axH.FontSize = 15;
    end
    xLab = suplabel(sprintf('Vector distances (%s)',vectorDistMetric),'y');
    xLab.FontSize = 30;
    yLab = suplabel(sprintf('Start Distance (%s)',startDistMetric),'x');
    yLab.FontSize = 30;
    
    %create new figure and plot 
    figH = figure;
    axH = axes;
    errorbar(1:nPoints,sameR2,abs(sameR2-rlo2),abs(sameR2-rup2));
    axH.YLim = [0 max(axH.YLim)+0.02];
    axH.XTick = 1:nPoints;
    axH.XTickLabel = pointLabels;
    axH.XTickLabelRotation = -45;
    axH.FontSize = 20;
    axH.YLabel.String = 'R^{2}';
    for pointInd = 1:nPoints
        if sameP(pointInd) < 0.001
            textH = text(pointInd,rup2(pointInd)+0.001,'***');
        elseif sameP(pointInd) < 0.01
            textH = text(pointInd,rup2(pointInd)+0.001,'**');
        elseif sameP(pointInd) < 0.05
            textH = text(pointInd,rup2(pointInd)+0.001,'*');
        end
        textH.FontSize = 30;
        textH.HorizontalAlignment = 'Center';
        textH.VerticalAlignment = 'bottom';
    end
    
    
end