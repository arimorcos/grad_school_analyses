function plotAccuracyIndSeg(classifierOut,varargin)
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

%% accuracy plot

%get nBinsPerSeg and nSeg
[nSeg,nBinsPerSeg] = size(accuracy);

%reshape accuracy
allAcc=reshape(accuracy',1,numel(accuracy));

%create figure
figH(1) = figure;

%get percentiles
if plotShuffle
    shufflePerc = prctile(shuffleAccuracy,percRange,3);
end

%plot accuracy
if nBinsPerSeg > 1
    plot(allAcc,'b','LineWidth',2);
    hold on;
    segRanges = 0:nBinsPerSeg:nBinsPerSeg*nSeg;
    for segInd = 1:nSeg+1
        %plot seg start
        line([segRanges(segInd) segRanges(segInd)],[0 100],'Color','r','LineStyle','--');
        
        if segInd <= nSeg
            %get temp classes
            nTempClasses = length(unique(realClass(:,segInd)));
            
            %plot chance line
            line([segRanges(segInd) segRanges(segInd+1)],...
                [100/nTempClasses 100/nTempClasses],'Color','k','LineStyle','--');
            
            if plotShuffle
                patchHandle = patch(cat(2,segRanges(segInd)+1:segRanges(segInd+1),...
                    segRanges(segInd+1):-1:segRanges(segInd)+1),...
                    cat(2,shufflePerc(segInd,:,1),shufflePerc(segInd,:,2)),[1 0 0]);
                set(patchHandle,'FaceAlpha',0.25,'EdgeColor','r');
            end
        end
    end
else
    scatter(0.5:(nSeg-0.5),allAcc,'bo','filled','sizedata',120);
    segRanges = 0:nBinsPerSeg:nBinsPerSeg*nSeg;
    for segInd = 1:nSeg+1
        %plot seg start
        line([segRanges(segInd) segRanges(segInd)],[0 100],'Color','r','LineStyle','--');
        
        if segInd <= nSeg
            %get temp classes
            nTempClasses = length(unique(realClass(:,segInd)));
            
            %plot chance line
            line([segRanges(segInd) segRanges(segInd+1)],...
                [100/nTempClasses 100/nTempClasses],'Color','k','LineStyle','--');
            
            if plotShuffle
                patchHandle = patch(cat(2,segRanges(segInd):segRanges(segInd+1),...
                    segRanges(segInd+1):-1:segRanges(segInd)),...
                    cat(2,repmat(shufflePerc(segInd,:,1),1,2),repmat(shufflePerc(segInd,:,2),1,2)),[1 0 0]);
                set(patchHandle,'FaceAlpha',0.25,'EdgeColor','r');
            end
        end
    end
end

xlabel('Bin #','FontSize',30);
ylabel('Classifier Accuracy','FontSize',30);

