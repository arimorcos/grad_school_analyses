function plotGuessesIndSeg(classifierOut,varargin)
plotShuffle = true;
percRange = [2.5 97.5];

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'plotshuffle'
                plotShuffle = varargin{argInd+1};
            case 'percrange'
                percRange = varargin{argInd+1};
        end
    end
end

%retrieve from classifierOut
accuracy = classifierOut(1).accuracy;
realClass = classifierOut(1).realClass;
classGuess = classifierOut(1).classGuess;
shuffleAccuracy = classifierOut(1).shuffleAccuracy;
shuffleGuess = classifierOut(1).shuffleGuess;

%get number of subsets
nSub = length(classifierOut);


%% misses plot
% plotAll = true;
% segToPlot = 1;
% if plotAll
%     segs = 1:nSeg;
% else
%     segs = segToPlot;
% end
%
% for segNum = segs
%     figH(length(figH)+1) = figure('Name',sprintf('Segment #%d',segNum));
%
%     %get classes
%     classes = unique(realClass(:,segNum));
%     nClasses = length(classes);
%
%     %get subplot rows
%     [nRows,nCol] = calcNSubplotRows(nClasses);
%
%     %loop through each class and create plot
%     for plotInd = 1:nClasses
%         subplot(nRows,nCol,plotInd);
%         hist(classGuess(realClass(:,segNum)==classes(plotInd),plotInd,segNum),classes);
%         title(sprintf('Real Class is %d',classes(plotInd)),'FontSize',15);
%         set(gca,'FontSize',15);
%         ylabel('Count','FontSize',15)
%     end
%
% end

%get nBinsPerSeg and nSeg
[nSeg,nBinsPerSeg] = size(accuracy);

%get unique classes in each segment
uniqueClasses = unique(realClass(:));
nClasses = length(uniqueClasses);

%set nRows and nCol
nRows = nSeg;
nCol = nClasses;

%create figure
figH = figure;

%initialize ahndles
axH = gobjects(nSeg,nCol);

%loop through each segment
for segInd = 1:nSeg
    for colInd = 1:nCol %loop through each plot
        %get current plot
        plotInd = colInd + (segInd-1)*nCol;
        
        %create subplot
        axH(segInd,colInd) = subplot(nRows,nCol,plotInd);
        
        
        hist(classGuess(realClass(:,segInd)==uniqueClasses(colInd),round(nBinsPerSeg/2),segInd),unique(realClass(:,segInd)));
        %         hist(classGuess(realClass(:,segInd)==uniqueClasses(colInd),nBinsPerSeg,segInd),unique(realClass(:,segInd)));
        if segInd == 1
            axPos = get(gca,'position');
            [~,h]=suplabel(sprintf('Actual: %d',uniqueClasses(colInd)),'t',[axPos(1:3) 1.05*axPos(4)]);
            set(h,'FontSize',12);
        end
        set(gca,'FontSize',10);
        if colInd == 1
            axPos = get(gca,'position');
            [~,h]=suplabel('Count','y',[0.98*axPos(1) axPos(2:4)]);
            set(h,'FontSize',12);
        end
        
        if ~any(realClass(:,segInd)==uniqueClasses(colInd)) % if no values
            delete(axH(segInd,colInd));
        end
    end
end