%get distance between intra and inter for each segment 

%%%%%%%%%%%%%%%%%%%%%%%% constants %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nSeg = 6;
usePCs = false;
varThresh = 0.75;
markerSize = 120;

%%%%%%%%%%%%%%%%%%%%%%%% CODE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%generate conditions
condArray = diag(ones(1,nSeg));
condArray(condArray == 0) = nan;

%get imSub
imSub = getTrials(dataCell,'imaging.imData==1');

%bin if necessary
if ~isfield(imSub{1}.imaging,'binnedDFFTraces')
    imSub = binFramesByYPos(imSub,10);
end

%get number of bins
nBins = length(imSub{1}.imaging.yPosBins);

%initialize
names = cell(1,nSeg);
meanDistances = zeros(nSeg,nBins);
sigDistances = zeros(size(meanDistances));

%cycle through each segment and get data
for i = 1:nSeg %for each segment 
    
    %generate name
    names{i} = sprintf('seg%d',i);
    
    %perform state space distance analysis 
    data.(names{i}) = calcStateSpaceDistance(imSub,{condArray(i,:),''},...
        usePCs,varThresh);
    
    %get distance between means
    meanDistances(i,:) = data.(names{i}).interDistancesMean - ...
        data.(names{i}).intraDistancesMean;
    
    %determine whether significant
    sigDistances(i,:) = ttest2(data.(names{i}).interDistances,data.(names{i}).intraDistances,...
        'dim',2,'alpha',0.05/nBins)';
end

%remove nans
sigDistances(isnan(sigDistances)) = 0;

%% plot
figure;
handles = gobjects(1,nSeg);
colors = distinguishable_colors(nSeg);
sigDistances = logical(sigDistances);
hold  on;
for i = 1:nSeg
    
    if sum(sigDistances(i,:))
        scatter(imSub{1}.imaging.yPosBins(sigDistances(i,:)),meanDistances(i,sigDistances(i,:)),...
            markerSize,colors(i,:),'fill');
    end
    
    handles(i) = scatter(imSub{1}.imaging.yPosBins(~sigDistances(i,:)),...
        meanDistances(i,~sigDistances(i,:)),markerSize,colors(i,:));
    
    line(imSub{1}.imaging.yPosBins,meanDistances(i,:),'Color',colors(i,:));
end

legend(handles,names,'Location','EastOutside');

ylabel('Inter distance - intra distance')
xlabel('Y Position (Units)');

title(sprintf('usePCS: %d  varThresh: %d',usePCs,varThresh));
    
        
%% plot 
figure;
colors = distinguishable_colors(nSeg);
hold on;
handles = gobjects(1,nSeg);
for i = 1:nSeg
    handles(i) = plot(imSub{1}.imaging.yPosBins,meanDistances(i,:),'Color',colors(i,:),...
        'linewidth',2);
end
legend(handles,names,'Location','EastOutside');

ylabel('Inter distance - intra distance')
xlabel('Y Position (Units)');
    
title(sprintf('usePCS: %d  varThresh: %d',usePCs,varThresh));
    