function [startDist,endDist] = calculateStateOffset(dataCell,varargin)
%calculateStateOffset.m Calculates and plots the offset before the same
%marginal segment relative to the offset after the same marginal segment
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%startDist - nSeg x 1 cell array of start distances
%endDist - nSeg x 1 cell array of end distances
%
%ASM 4/15

shouldPlot = true;
nShuffles = 1000;
shouldShuffle = true;
confInt = 95;
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'shouldplot'
                shouldPlot = varargin{argInd+1};
            case 'shouldshuffle'
                shouldShuffle = varargin{argInd+1};
            case 'nshuffles'
                nShuffles = varargin{argInd+1};
            case 'confint'
                confInt = varargin{argInd+1};
        end
    end
end

%get traces
[~,traces] = catBinnedTraces(dataCell);

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%get tracePoints
tracePoints = getMazePoints(traces,yPosBins);

%get mazePatterns
mazePatterns = getMazePatterns(dataCell);
nSeg = size(mazePatterns,2);

%initialize
startDist = cell(nSeg,2);
endDist = cell(nSeg,2);

%loop through each segment
for segInd = 1:nSeg
    
%     %get left and right ind
%     leftInd = logical(mazePatterns(:,segInd));
%     rightInd = ~mazePatterns(:,segInd);
%     
%     %calculate left and right starting pairwise distance
%     startDistLeft = pdist(squeeze(tracePoints(:,segInd,leftInd))');
%     startDistRight = pdist(squeeze(tracePoints(:,segInd,rightInd))');
%     
%     %calculate left and right ending pairwise distances
%     endDistLeft = pdist(squeeze(tracePoints(:,segInd+1,leftInd))');
%     endDistRight = pdist(squeeze(tracePoints(:,segInd+1,rightInd))');
%     
%     %store
%     startDist{segInd} = cat(2,startDistLeft,startDistRight);
%     endDist{segInd} = cat(2,endDistLeft,endDistRight);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % take all trial pairs 
    nTrials = size(mazePatterns,1);
    allPairs = allcomb(1:nTrials,1:nTrials);
    allPairs(allPairs(:,2) <= allPairs(:,1),:) = [];
    
    %get pairs with the same and different marginal segment 
    marginalSeg = [mazePatterns(allPairs(:,1),segInd) ...
        mazePatterns(allPairs(:,2),segInd)];
    sameMarginalSeg = marginalSeg(:,1) == marginalSeg(:,2);
    diffMarginalSeg = marginalSeg(:,1) ~= marginalSeg(:,2);
    sameMarginalSegPairs = allPairs(sameMarginalSeg,:);
    diffMarginalSegPairs = allPairs(diffMarginalSeg,:);
    
    % calculate the distances 
    startingDistances = squareform(pdist(squeeze(tracePoints(:,segInd,:))'));
    endingDistances = squareform(pdist(squeeze(tracePoints(:,segInd+1,:))'));
    
    %get indices for same and different marginal segment 
    sameMarginalSegInd = sub2ind(size(startingDistances),...
        sameMarginalSegPairs(:,1),sameMarginalSegPairs(:,2));
    diffMarginalSegInd = sub2ind(size(startingDistances),...
        diffMarginalSegPairs(:,1),diffMarginalSegPairs(:,2));
    
    %get relevant distances and store 
    startDist{segInd,1} = startingDistances(sameMarginalSegInd);
    startDist{segInd,2} = startingDistances(diffMarginalSegInd);
    endDist{segInd,1} = endingDistances(sameMarginalSegInd);
    endDist{segInd,2} = endingDistances(diffMarginalSegInd);
    
end

if shouldShuffle
    %calculate mse
    actualMSESame = getMSEDist(startDist(:,1),endDist(:,1));
    actualMSEDiff = getMSEDist(startDist(:,2),endDist(:,2));
        
    shuffleMSESame = nan(nShuffles,nSeg);
    shuffleMSEDiff = nan(nShuffles,nSeg);
    shuffleSlopeDifference = nan(nShuffles,nSeg);
    for shuffleInd = 1:nShuffles 
        
        %shuffle each array 
        shuffledStart = cellfun(@shuffleArray,startDist,'UniformOutput',false);
        
        %get mse 
        shuffleMSESame(shuffleInd,:) = getMSEDist(shuffledStart(:,1),endDist(:,1));
        shuffleMSEDiff(shuffleInd,:) = getMSEDist(shuffledStart(:,2),endDist(:,2));
        
        %get same vs. diff shuffle 
        for segInd = 1:nSeg
           
            %concatenate all trials
            allStart = cat(1,startDist{segInd,:});
            nSame = length(startDist{segInd,1});
            allEnd = cat(1,endDist{segInd,:});
            
            %shuffle 
            shuffleStart = shuffleArray(allStart);
            shuffleEnd = shuffleArray(allEnd);
            
            %fit 
            sameCoeff = robustfit(shuffleStart(1:nSame),shuffleEnd(1:nSame));
            diffCoeff = robustfit(shuffleStart(nSame+1:end),shuffleEnd(nSame+1:end));
            
            %get slope 
            shuffleSlopeDifference(shuffleInd,segInd) = diffCoeff(2) - sameCoeff(2);            
            
        end
        %display progress
        dispProgress('Shuffling distances %d/%d',shuffleInd,shuffleInd,nShuffles);
        
    end
    
end

%plot
if shouldPlot
    figH = figure;
    [nRows, nCol] = calcNSubplotRows(nSeg);
    actualSlopeDifference = nan(nSeg,1);
    for segInd = 1:nSeg
        axH = subplot(nRows,nCol,segInd);
        hold(axH,'on');
        
        %plot same 
        scatSame = scatter(startDist{segInd,1},endDist{segInd,1});
        scatSame.MarkerEdgeColor = [0.7 0.8 0.8];
        
        %plot diff
        scatDiff = scatter(startDist{segInd,2},endDist{segInd,2});
        scatDiff.MarkerEdgeColor = [0.8 0.8 0.7];
        
        %convert to square
        minVal = min(cat(1,cat(1,startDist{segInd,:}),cat(1,endDist{segInd,:})));
        maxVal = max(cat(1,cat(1,startDist{segInd,:}),cat(1,endDist{segInd,:})));
        axH.XLim = [minVal maxVal];
        axH.YLim = [minVal maxVal];
        axis(axH,'square');
        
        lineH = line([minVal maxVal],[minVal maxVal]);
        lineH.Color = 'k';
        lineH.LineStyle = '--';
        
        %fit lines and plot 
        sameCoeff = robustfit(startDist{segInd,1},endDist{segInd,1});
        xVals = linspace(minVal,maxVal,100);
        yVals = sameCoeff(2)*xVals + sameCoeff(1);
        sameFit = plot(xVals,yVals,'Color','b');
        
        diffCoeff = robustfit(startDist{segInd,2},endDist{segInd,2});
        xVals = linspace(minVal,maxVal,100);
        yVals = diffCoeff(2)*xVals + diffCoeff(1);
        diffFit = plot(xVals,yVals,'Color','r');
        actualSlopeDifference(segInd) = diffCoeff(2) - sameCoeff(2);
        
        axH.Title.String = sprintf('Segment %d',segInd);
        axH.FontSize = 20;
    end
    
    %add labels
    xLab = suplabel('Start Distance', 'x');
    xLab.XLabel.FontSize = 30;
    yLab = suplabel('End Distance', 'y');
    yLab.YLabel.FontSize = 30;
    
    %add legend 
    legH = legend([scatSame, scatDiff, sameFit, diffFit],{'Same Segment', 'Diff Segment',...
        'Same Segment Fit', 'Diff Segment Fit'},'Location','Best');
    legH.FontSize = 10;
    
    %plot shuffle
    if shouldShuffle 
       %create new figure 
       figShuff = figure; 
       
       %%%%%%%%%%%%%% mse
       axShuffMSE = subplot(1,2,1);
       hold(axShuffMSE,'on');
       
       %get confidence intervals 
       lowInd = (100-confInt)/2;
       highInd = 100-lowInd;
       confValsSame = prctile(shuffleMSESame,[lowInd highInd]);
       confValsSame = abs(bsxfun(@minus,confValsSame,median(shuffleMSESame)));
       confValsDiff = prctile(shuffleMSEDiff,[lowInd highInd]);
       confValsDiff = abs(bsxfun(@minus,confValsDiff,median(confValsDiff)));
       
       %plot 
       scatMSESame = scatter(0.8:1:nSeg-0.2,actualMSESame);
       scatMSEDiff = scatter(1.2:1:nSeg+0.2,actualMSEDiff);       
       errMSESame = errorbar(0.8:1:nSeg-0.2,median(shuffleMSESame),confValsSame(1,:),confValsSame(2,:));
       errMSEDiff = errorbar(1.2:1:nSeg+0.2,median(shuffleMSEDiff),confValsDiff(1,:),confValsDiff(2,:));
       
       %customize
       scatMSESame.MarkerFaceColor = 'b';
       scatMSESame.SizeData = 100;
       errMSESame.LineStyle = 'none';
       errMSESame.Color = 'b';
       errMSESame.LineWidth = 2;
       
       scatMSEDiff.MarkerFaceColor = 'r';
       scatMSEDiff.SizeData = 100;
       errMSEDiff.LineStyle = 'none';
       errMSEDiff.Color = 'r';
       errMSEDiff.LineWidth = 2;       
       
       axis(axShuffMSE,'square');
       axShuffMSE.FontSize = 20;
       
       %label
       axShuffMSE.YLabel.String = 'Mean Squared Error';
       axShuffMSE.YLabel.FontSize = 30;
       axShuffMSE.XLabel.String = 'Segment #';
       axShuffMSE.XLabel.FontSize = 30;
       
       %add legend
       legend([scatMSESame,scatMSEDiff],{'Same Segment','Diff Segment'},...
           'Location','Best');
       
       %%%%%%%%%%%%%%% difference in slope 
       axShuffSlope = subplot(1,2,2);
       hold(axShuffSlope,'on');
       
       %get confidence intervals 
       lowInd = (100-confInt)/2;
       highInd = 100-lowInd;
       confVals = prctile(shuffleSlopeDifference,[lowInd highInd]);
       confVals = abs(bsxfun(@minus,confVals,median(confVals)));
       
       %plot 
       scatMSE = scatter(1:nSeg,actualSlopeDifference);
       errMSE = errorbar(1:nSeg,median(shuffleSlopeDifference),confVals(1,:),confVals(2,:));
       
       %customize
       scatMSE.MarkerFaceColor = 'flat';
       scatMSE.SizeData = 100;
       errMSE.LineStyle = 'none';
       errMSE.Color = 'b';
       errMSE.LineWidth = 2;       
       
       axis(axShuffSlope,'square');
       axShuffSlope.FontSize = 20;
       
       %label
       axShuffSlope.YLabel.String = 'Different segment slope - same segment slope';
       axShuffSlope.YLabel.FontSize = 30;
       axShuffSlope.XLabel.String = 'Segment #';
       axShuffSlope.XLabel.FontSize = 30;
    end
end
end

function mse = getMSEDist(startDist,endDist)

nSeg = length(startDist);
mse = nan(nSeg,1);
for segInd = 1:nSeg
    mse(segInd) = mean((endDist{segInd} - startDist{segInd}).^2);
end
end
