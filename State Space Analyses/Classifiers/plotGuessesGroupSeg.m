function plotGuessesGroupSeg(classifierOut,varargin)
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

%get nBinsPerSeg and nSeg
[nSeg,nBinsPerSeg] = size(accuracy);

%get unique classes in each segment
uniqueClasses = unique(realClass(:));
nClasses = length(uniqueClasses);


%create figure
figH = figure;

[nRows,nCol] = calcNSubplotRows(nClasses);

%initialize ahndles
axH = gobjects(1,nCol);

%loop through each segment
for colInd = 1:nClasses %loop through each plot
    %get current plot
    plotInd = colInd;
    
    %create subplot
    axH(1,colInd) = subplot(nRows,nCol,plotInd);
    
    
    hist(classGuess(realClass==uniqueClasses(colInd),round(nBinsPerSeg/2)),unique(realClass));
    %         hist(classGuess(realClass(:,segInd)==uniqueClasses(colInd),nBinsPerSeg,segInd),unique(realClass(:,segInd)));
    
    axPos = get(gca,'position');
    [~,h]=suplabel(sprintf('Actual: %d',uniqueClasses(colInd)),'t',[axPos(1:3) 1.05*axPos(4)]);
    set(h,'FontSize',12);
    
    set(gca,'FontSize',10);
    
    
    if ~any(realClass==uniqueClasses(colInd)) % if no values
        delete(axH(1,colInd));
    end
    
end
[~,h]=suplabel('Count','y');
set(h,'FontSize',30,'FontWeight','Bold');
[~,h]=suplabel('Net Evidence Guess','x');
set(h,'FontSize',30,'FontWeight','Bold');
