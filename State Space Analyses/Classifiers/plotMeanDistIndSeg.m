function figH = plotMeanDistIndSeg(classifierOut,varargin)
%plotNetEvClassfierIndSeg.m Plot classifier for individual segments
%
%INPUTS
%accuracy - nSeg x nBins array containing accuracy for each bin of each
%   segment
%classGuess - nTrials x nBins x nSeg array of classifier guesses
%realClass - nTrials x nSeg array of actual net evidence
%shuffleAccuracy - nSeg x nBins x nShuffles array containing accuracy for
%   each bin of each segment of each shuffle
%
%OUTPUTS
%figH - 1 x 2 array of figure handles
%
%ASM 9/14

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

%% plot mean distances

%get nBinsPerSeg and nSeg
[nSeg] = size(accuracy,1);

%get unique classes in each segment
uniqueClasses = unique(realClass(:));
nClassesAll = length(uniqueClasses);

%set nRows and nCol
nCol = nClassesAll;

%create figure
figH = figure;

%initialize ahndles
axH = gobjects(nSeg,nCol);

%loop through each segment
for segInd = 1:nSeg
    
    %get distance
    tempDist = classifierOut(1).distances{segInd};
    
    %squeeze
    tempDist = squeeze(tempDist);
    
    %transpose so it's nTrials x nClasses
    tempDist = tempDist';
    
    %get classes
    tempClasses = classifierOut(1).distClasses{segInd};
    
    %squeeze shuffle
    tempShuffle = cellfun(@(x) squeeze(x{segInd})',classifierOut(1).shuffleDistances,'UniformOutput',false);
    
    %get nClasses
    nClasses = length(tempClasses);
    
    %initialize
    meanClassSub = zeros(nClasses);
    stdClassSub = zeros(nClasses);
    shufflePerc = zeros(2,nClasses,nClasses);
    
    for classInd = 1:nClassesAll
        
        %get current plot
        plotInd = classInd + (segInd-1)*nClassesAll;
        
        %create subplot
        axH(segInd,classInd) = subplot(nSeg,nCol,plotInd);
        
        %label
        if segInd == 1
            axPos = get(axH(segInd,classInd),'position');
            [~,h]=suplabel(sprintf('Actual: %d',uniqueClasses(classInd)),'t',[axPos(1:3) 1.08*axPos(4)]);
            set(h,'FontSize',12,'FontWeight','bold');
        end
        set(gca,'FontSize',10);
        if classInd == 1
            axPos = get(axH(segInd,classInd),'position');
            [~,h]=suplabel(sprintf('Segment #%d',segInd),'y',[0.98*axPos(1) axPos(2:4)]);
            set(h,'FontSize',12,'FontWeight','bold');
        end
        
        if ~any(classifierOut(1).realClass(:,segInd)==uniqueClasses(classInd)) %skip if no matches
            delete(axH(segInd,classInd));
            continue;
        else
            axes(axH(segInd,classInd));
        end
        
        %get subset
        classIndices = classifierOut(1).realClass(:,segInd)==uniqueClasses(classInd);
        classSub = tempDist(classIndices,:);
        
        %get mean and std
        meanClassSub(classInd,:) = mean(classSub);
        stdClassSub(classInd,:) = std(classSub);
        
        %get shuffle mean
        shuffleMeans = cellfun(@(x) mean(x(classIndices,:)),tempShuffle,'UniformOutput',false);
        shuffleMeans = cat(1,shuffleMeans{:}); %concatenate
        shufflePerc(:,:,classInd) = prctile(shuffleMeans,percRange);
        
        %plot actual data
%         errorbar(tempClasses,meanClassSub(classInd,:),stdClassSub(classInd,:),...
%             'Marker','o','MarkerFaceColor','b','MarkerEdgeColor',...
%             'b','MarkerSize',5);
        errorbar(tempClasses,meanClassSub(classInd,:),zeros(size(meanClassSub(classInd,:))),...
            'Marker','o','MarkerFaceColor','b','MarkerEdgeColor',...
            'b','MarkerSize',5);
        
        %plot shuffle
        patchHandle = patch(cat(2,tempClasses',fliplr(tempClasses')),...
            cat(2,shufflePerc(1,:,classInd),shufflePerc(2,:,classInd)),[1 0 0]);
        set(patchHandle,'FaceAlpha',0.1,'EdgeColor','r');
        
        %set ticks
        set(axH(segInd,classInd),'FontSize',12,'xtick',tempClasses);
        
        
    end

    
    
end

[~,yH]=suplabel('Distance','y',[.06 .08 .84 .84]);
set(yH,'FontSize',30,'FontWeight','bold');

