function figH = plotIntraInterDistIndSeg(classifierOut,varargin)
%plotIntraInterDistIndSeg.m Plot classifier for individual segments
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
includeZeroInter = true;

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
            case 'includezerointer'
                includeZeroInter = varargin{argInd+1};
            otherwise 
                error(sprintf('Argument %s not found',varargin{argInd}));
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

%create figure
figH = figure;

%loop through each segment
for segInd = 1:nSeg
    
    %get classes
    tempClasses = classifierOut(1).distClasses{segInd};
    
    %skip if no unique classes
    if length(unique(abs(tempClasses)))==1
        continue;
    end
    
    %get distance
    tempDist = classifierOut(1).distances{segInd};
    
    %squeeze
    tempDist = squeeze(tempDist);
    
    %transpose so it's nTrials x nClasses
    tempDist = tempDist';
    
    %squeeze shuffle
    tempShuffle = cellfun(@(x) squeeze(x{segInd})',classifierOut(1).shuffleDistances,'UniformOutput',false);
    
    %get nClasses
    nClasses = length(tempClasses);
    
    %initialize
    intraSub = cell(1,nClasses);
    interSub = cell(1,nClasses);
    shuffleInterSub = cell(1,nClasses);
    shuffleIntraSub = cell(1,nClasses);
    
    for classInd = 1:nClasses
        
        %get subset
        classIndices = classifierOut(1).realClass(:,segInd)==tempClasses(classInd);
        classSub = tempDist(classIndices,:);
        tempShuffleSub = cellfun(@(x) x(classIndices,:),tempShuffle,'UniformOutput',false);
        
        %get intra and inter sub
        intraSub{classInd} = classSub(:,tempClasses(classInd)==tempClasses);
        if includeZeroInter
            interInd = tempClasses(classInd)~=tempClasses &...
                (sign(tempClasses(classInd))==sign(tempClasses) | sign(tempClasses) == 0);
        else
            interInd = tempClasses(classInd)~=tempClasses &...
                sign(tempClasses(classInd))==sign(tempClasses);
        end
        interSub{classInd} = classSub(:,interInd); %take intra groups with the same sign or 0
        
        %reshape interSub into column vector
        interSub{classInd} = interSub{classInd}(:);
        
        %get shuffle subs for inter and intra
        shuffleIntraSub{classInd} = cellfun(@(x) x(:,tempClasses(classInd)==tempClasses),tempShuffleSub,'UniformOutput',false);
        shuffleInterSub{classInd} = cellfun(@(x) x(:,interInd),tempShuffleSub,'UniformOutput',false);
        shuffleInterSub{classInd} = cellfun(@(x) x(:),shuffleInterSub{classInd},'UniformOutput',false);
        
        %convert to arrays
        shuffleIntraSub{classInd} = cat(2,shuffleIntraSub{classInd}{:});
        shuffleInterSub{classInd} = cat(2,shuffleInterSub{classInd}{:});
        
    end
    
    %get abs(netEv)
    absNetEv = unique(abs(tempClasses));
    absNetEv(absNetEv==0) = []; %remove zero values
    
    %pool intra/inter from same abs(netEv)
    absIntraSub = cell(1,length(absNetEv));
    absInterSub = cell(1,length(absNetEv));
    absShuffleIntraSub = cell(1,length(absNetEv));
    absShuffleInterSub = cell(1,length(absNetEv));
    for evCond = 1:length(absNetEv)
        sameInd = abs(tempClasses) == absNetEv(evCond);
        absIntraSub{evCond} = cat(1,intraSub{sameInd});
        absInterSub{evCond} = cat(1,interSub{sameInd});
        absShuffleIntraSub{evCond} = cat(1,shuffleIntraSub{sameInd});
        absShuffleInterSub{evCond} = cat(1,shuffleInterSub{sameInd});
    end
        
        
    %get mean and std
    meanInterSub = cellfun(@mean,absInterSub);
    meanIntraSub = cellfun(@mean,absIntraSub);
    meanShuffleIntraSub = cellfun(@mean,absShuffleIntraSub,'UniformOutput',false);
    meanShuffleInterSub = cellfun(@mean,absShuffleInterSub,'UniformOutput',false);
    
    %get diff
    realDiff = meanInterSub - meanIntraSub;   
    shuffleDiffs = arrayfun(@(x) meanShuffleInterSub{x} - meanShuffleIntraSub{x},...
        1:length(absNetEv),'UniformOutput',false);
    
    %get percentiles
    shufflePerc = cellfun(@(x) prctile(x,percRange),shuffleDiffs,'UniformOutput',false);
    shufflePerc = cat(1,shufflePerc{:});
    
    %plot actual data
    subplot(1,nSeg,segInd);
    bar(absNetEv,realDiff);
    hold on;
    errorbar(absNetEv,zeros(length(absNetEv),1),abs(shufflePerc(:,1)),abs(shufflePerc(:,2)),...
        'LineStyle','none','Color','r','LineWidth',2);
    xlabel(sprintf('Segment #%d',segInd),'FontSize',30);
    
    
    
end

[~,yH]=suplabel('Inter - Intra Distance','y',[.06 .08 .84 .84]);
set(yH,'FontSize',30,'FontWeight','bold');

