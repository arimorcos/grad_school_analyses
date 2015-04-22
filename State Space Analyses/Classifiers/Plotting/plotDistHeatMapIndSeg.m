function plotDistHeatMapIndSeg(classifierOut,varargin)

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

%% plot distance heat map

%get nBinsPerSeg and nSeg
[nSeg,nBinsPerSeg] = size(accuracy);

%loop through each seg
for segInd = 1:nSeg
    
    %get distance
    tempDist = classifierOut(1).distances{segInd};
    
    %squeeze
    tempDist = squeeze(tempDist);
    
    %transpose so it's nTrials x nClasses
    tempDist = tempDist';
    
    %get classes
    tempClasses = classifierOut(1).distClasses{segInd};
    
    %sort trials by realClass
    [sortedClass,sortInd] = sort(classifierOut(1).realClass(:,segInd));
    
    %sort distances by realClass
    tempDistSorted = tempDist(sortInd,:);
    
    %create a figure;
    figH = figure('Name',sprintf('Segment #%d',segInd));
    
    %loop through each class
    nClasses = length(tempClasses);
    for classInd = 1:nClasses
        
        %get position
        [subPos] = calcSubplotDivPositions(nClasses,1,2,...
            [0.3 0.7],classInd,[0.08 0.1],[0.1 0.02],[],0.005);
        
        %create subplot
        %             subplot(nClasses,1,classInd);
        ax1=subplot('position',subPos(2,:));
        
        %get subset
        classSub = tempDistSorted(sortedClass==tempClasses(classInd),:);
        
        %plot heatmap
        imagesc(tempClasses,1:size(classSub,1),classSub);
        
        %set ticks
        set(gca,'xtick',classifierOut(1).distClasses{segInd});
        set(gca,'xticklabel',[]);
        set(gca,'FontSize',15);
        
        %label
        ylabel(num2str(tempClasses(classInd)),'FontSize',20,'FontWeight','Bold');
        
        %create next plot
        ax2=subplot('position',subPos(1,:));
        
        %plot mean
        plot(tempClasses,mean(classSub),'b');
        set(gca,'ytick',[]);
        if classInd ~= nClasses
            set(gca,'xticklabel',[],'xtick',[]);
        end
        
        %link
        linkaxes([ax1 ax2],'x');
    end
    
    %label
    [~,xSup]=suplabel('Actual Class','x',[.08 0.1 .82 .88]);
    set(xSup,'FontSize',30);
    [~,ySup] = suplabel('Trial # (sorted)','y',[.04 0.1 .82 .88]);
    set(ySup,'FontSize',30);
    
end

