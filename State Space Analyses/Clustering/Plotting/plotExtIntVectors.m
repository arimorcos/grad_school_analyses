function plotExtIntVectors(dataCell,varargin)
%plotExtIntVectors.m Plots external vs internal vector similarity vs.
%starting distance
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OPTIONAL INPUTS
%variabilityMetric - Options are 'fracMode', for fraction of trials in mode
%   cluster, and 'aucCDF' for area under cdf curve
%
%
%OUTPUTS
%
%ASM 4/15

shouldShuffle = true;
nShuffles = 200;
shouldPlot = true;
startDistMetric = 'euclidean';
vectorDistMetric = 'euclidean';
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
nPoints = nSeg + 1;
tracePoints = tracePoints(:,1:nPoints,:);


%%%%% Calculate distances
% take all trial pairs
allPairs = allcomb(1:nTrials,1:nTrials);
allPairs(allPairs(:,2) <= allPairs(:,1),:) = []; %crop out duplicates and same trial pairs

%initialize 
externalStartDist = cell(nSeg,1);
internalStartDist = cell(nSeg,1);
externalVecDist = cell(nSeg,1);
internalVecDist = cell(nSeg,1);

%loop through each segment
for segInd = 1:nSeg
    
    %get current net evidence
    currNetEv = netEvidence(:,segInd);
    
    %get cluster pairs with the same net evidence
    pairNetEv = [currNetEv(allPairs(:,1)) currNetEv(allPairs(:,2))];
    sameNetEv = pairNetEv(:,1) == pairNetEv(:,2);
    tempPairs = allPairs(sameNetEv,:);
    
    % calculate starting distance for all pairs
    allStartDists = squareform(pdist(squeeze(tracePoints(:,segInd,:))',startDistMetric));
    
    %filter pairs for external and internal
    externalPairs = tempPairs(mazePatterns(tempPairs(:,1),segInd) ~= ...
        mazePatterns(tempPairs(:,2),segInd),:); %keep pairs with different marginal segments
    internalPairs = tempPairs(mazePatterns(tempPairs(:,1),segInd) == ...
        mazePatterns(tempPairs(:,2),segInd),:); %keep pairs with the same marginal segments
    
    %get indices to keep
    externalInd = sub2ind(size(allStartDists),externalPairs(:,1),externalPairs(:,2));
    internalInd = sub2ind(size(allStartDists),internalPairs(:,1),internalPairs(:,2));
    
    %get indices and crop to relevant starting distances
    externalStartDist{segInd} = allStartDists(externalInd);
    internalStartDist{segInd} = allStartDists(internalInd);
    
    %get vectors
    trialVecs = squeeze(tracePoints(:,segInd+1,:))' - squeeze(tracePoints(:,segInd,:))';
    
    %get distances
    allVecDists = squareform(pdist(trialVecs,vectorDistMetric));
    
    %crop
    externalVecDist{segInd} = allVecDists(externalInd);
    internalVecDist{segInd} = allVecDists(internalInd);
    
    
end

%%% plot for each
if shouldPlot
    figH = figure;
    [nRows, nCol] = calcNSubplotRows(nSeg);
    for segInd = 1:nSeg
%         axH = subplot(nRows,nCol,segInd);
%         hold(axH,'on');
        plotPos = calcSubplotDivPositions(nRows,nCol,1,1,segInd);
        panelH = uipanel('Position',plotPos);
        
        % scatter
%         scatInternal = scatter(internalStartDist{segInd},internalVecDist{segInd});
%         scatExternal = scatter(externalStartDist{segInd},externalVecDist{segInd});
%         
%         %color 
%         scatInternal.MarkerEdgeColor = 'r';
%         scatExternal.MarkerEdgeColor = 'b';

        nInternal = length(internalStartDist{segInd});
        nExternal = length(externalStartDist{segInd});
        allStartDist = cat(1,internalStartDist{segInd},externalStartDist{segInd});
        allVecDist = cat(1,internalVecDist{segInd},externalVecDist{segInd});
        groupVec = cell(length(allVecDist),1);
        groupVec(1:nInternal) = repmat({'Same Marginal Segment'},nInternal,1);
        groupVec(nInternal+1:end) = repmat({'Different Marginal Segment'},nExternal,1);
        scatH = scatterhist(allStartDist,allVecDist,'Group',groupVec,'Parent',panelH);
        
        %get corrcoef 
        [sameR,p] = corrcoef(internalVecDist{segInd},internalStartDist{segInd});
        sameP = p(2,1);
        [diffR,p] = corrcoef(externalVecDist{segInd},externalStartDist{segInd});
        diffP = p(2,1);
        sameR2 = sameR(2,1)^2;
        diffR2 = diffR(2,1)^2;
        
        %add text 
        maxY = max(scatH(1).YLim);
        minX = min(scatH(1).XLim);
        diffColor = scatH(1).Children(1).Color;
        sameColor = scatH(1).Children(2).Color;
        sameText = text(minX+0.2,maxY-0.05,sprintf('R^{2}: %.3f, p = %.1d',sameR2,sameP),...
            'VerticalAlignment','Top','HorizontalAlignment','Left');
        diffText = text(minX+0.2,maxY-0.15,sprintf('R^{2}: %.3f, p = %.1d',diffR2,diffP),...
            'VerticalAlignment','Top','HorizontalAlignment','Left');
        sameText.Color = sameColor;
        diffText.Color = diffColor;
                
        %labels 
        scatH(1).YLabel.String = sprintf('Vector distances (%s)',vectorDistMetric);
        scatH(1).XLabel.String = sprintf('Start Distance (%s)',startDistMetric);
        scatH(1).Title.String = sprintf('Segment %d',segInd);
    end
   
end