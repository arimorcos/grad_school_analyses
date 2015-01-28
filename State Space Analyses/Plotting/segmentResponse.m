%%
outFileName = 'D:\Dropbox\Lab\Presentations\Lab Meetings - Data\140513\100_131104_segment_all Neurons';

%%
% filterThreshDFF; %filter and threshold the neurons

%%
binSize = 5;

imSub = getTrials(dataCell,'imaging.imData==1');

%bin if necessary
if ~isfield(imSub{1}.imaging,'binnedDFFTraces')
    imSub = binFramesByYPos(imSub,binSize,[-40 620]);
end

%get number of bins
nBins = length(imSub{1}.imaging.yPosBins);

%filter imSub
imSub = getTrials(imSub,'result.correct==1;maze.crutchTrial==0;maze.numLeft==1,2,3,4,5');


%get neuronal traces
dFFTraces = catBinnedTraces(imSub);

nCells = size(dFFTraces,1);

%segment starts
segStarts = [0 80 160 240 320 400];
segEnds = [80 160 240 320 400 480];

%get maze patterns
[mazePatterns,nSeg] = getMazePatterns(imSub);
mazePatterns = randi([0 1],size(mazePatterns));

%%

%get segment bins
segBinRange = zeros(nSeg,2);
for i = 1:nSeg
    
    segBinRange(i,1) = find(imSub{1}.imaging.yPosBins >= segStarts(i),1,'first');
    segBinRange(i,2) = find(imSub{1}.imaging.yPosBins < segEnds(i),1,'last');
    
end
    
%get mean activity for each segment type
segActivity = cell(nSeg,2);
for i = 1:nSeg
    
    segActivity{i,1} = dFFTraces(:,segBinRange(i,1):segBinRange(i,2),logical(mazePatterns(:,i)));
    segActivity{i,2} = dFFTraces(:,segBinRange(i,1):segBinRange(i,2),~logical(mazePatterns(:,i)));
end

%get mean and std of activity 
meanSegActivity = cellfun(@(x) mean(x,3),segActivity,'UniformOutput',false);
stdSegActivity = cellfun(@(x) std(x,0,3),segActivity,'UniformOutput',false);
semSegActivity = cellfun(@(x) std(x,0,3)/sqrt(size(x,3)),segActivity,'UniformOutput',false);
    
%%get selectivity index
selectivity = cellfun(@(x,y) (x-y)./(x+y),meanSegActivity(:,1),meanSegActivity(:,2),'UniformOutput',false);
selectivity = cellfun(@nanzero,selectivity,'UniformOutput',false);


%% analysis

%get mean(abs(selectivity)) for each seg
meanSel = mean(cell2mat(cellfun(@(x) mean(abs(x)),selectivity,'UniformOutput',false)),2);
medianSel = mean(cell2mat(cellfun(@(x) median(abs(x)),selectivity,'UniformOutput',false)),2);
stdSel = mean(cell2mat(cellfun(@(x) std(abs(x)),selectivity,'UniformOutput',false)),2);

%% export
%delete file if exists
if exist([outFileName,'.pdf'],'file')
    delete([outFileName,'.pdf']);
end

%create waitbar
hWait = waitbar(0,'Creating figures...');

%get bins
bins = segStarts(1):binSize:(segEnds(end)-binSize);
segBorders = unique([segStarts segEnds]);

%create tempSegActivity padded with nans 
maxTrialsLeft = max(cellfun(@(x) size(x,3),segActivity(:,1)));
maxTrialsRight = max(cellfun(@(x) size(x,3),segActivity(:,2)));
tempSegActivity = segActivity;
for i = 1:nSeg 
    tempSegActivity{i,1} = cat(3,tempSegActivity{i,1},-10*ones(size(segActivity{i,1},1),...
        size(segActivity{i,1},2),maxTrialsLeft - size(segActivity{i,1},3)));
    tempSegActivity{i,2} = cat(3,tempSegActivity{i,2},-10*ones(size(segActivity{i,2},1),...
        size(segActivity{i,2},2),maxTrialsRight - size(segActivity{i,2},3)));
end
minData = -10;
%cycle through each cell and create figure
for i = 1:nCells % for each cell
    
    %find min max of data
    minData = min(min(dFFTraces(i,:,:)));
    maxData = max(max(dFFTraces(i,:,:)));
    
    %     create figure;
    figHandle = figure('Visible','off');
    % figure;
    
    %create left segment plot
    subplot(2,2,1);
    leftSegments = cat(2,tempSegActivity{:,1});
    imagesc(bins,1:size(leftSegments,3),squeeze(leftSegments(i,:,:))',[minData maxData]);
    xlabel('Binned Position');
    ylabel('Trial #');
    axis square;
    colorbar;
    title('Left Trials');
    line(repmat(segBorders',1,2)',repmat([-5 size(leftSegments,3)+1],nSeg+1,1)',...
        'Color','r','LineWidth',2,'LineStyle','--');
    
    %create right trial plot
    subplot(2,2,3);
    rightSegments = cat(2,tempSegActivity{:,2});
    imagesc(bins,1:size(rightSegments,3),squeeze(rightSegments(i,:,:))',[minData maxData]);
    xlabel('Binned Position');
    ylabel('Trial #');
    axis square;
    colorbar;
    title('Right Trials');
    line(repmat(segBorders',1,2)',repmat([-5 size(rightSegments,3)+1],nSeg+1,1)',...
        'Color','r','LineWidth',2,'LineStyle','--');
    
    %create mean plot
    subplot(2,2,2);
    meanSegmentsLeft = cat(2,meanSegActivity{:,1});
    meanSegmentsRight = cat(2,meanSegActivity{:,2});
    semSegmentsLeft = cat(2,semSegActivity{:,1});
    semSegmentsRight = cat(2,semSegActivity{:,2});
    h1 = shadedErrorBar(bins,meanSegmentsLeft(i,:),semSegmentsLeft(i,:),'b');
    hold on;
    h2 = shadedErrorBar(bins,meanSegmentsRight(i,:),semSegmentsRight(i,:),'r');
    xlabel('Binned Position');
    ylabel('Mean dF/F +- SEM');
    legend([h1.mainLine h2.mainLine],'Left','Right','Location','NorthWest');
    plotRange = get(gca,'ylim');
    line(repmat(segBorders',1,2)',repmat(plotRange,nSeg+1,1)',...
        'Color','k','LineWidth',2,'LineStyle','--');
    title('Mean Activity');
    axis square;
    xlim([bins(1) bins(end)]);
    
    %create selectivity plot
    subplot(2,2,4);
    allSelectivity = cat(2,selectivity{:});
    plot(bins,allSelectivity(i,:));
    ylim([-1 1]);
    ylabel('Selectivity Index');
    xlabel('Binned Position');
    title('Selectivity');
    axis square;
    hold on;
%     plot(bins,sig(i,:),'k');
    xlim([bins(1) bins(end)]);
    
    %title
    suplabel(sprintf('Cell %d',i),'t');
    
    %maximize
    set(figHandle,'Units','Normalized','OuterPosition',[0 0 1 1]);
    
    %export
    export_fig(outFileName, '-pdf', '-nocrop', '-append', figHandle);
    
    %delete figure
    delete(figHandle);
    
    %update waitbar
    waitbar(i/nCells,hWait,sprintf('Creating figure %d/%d...',i,nCells)); %update waitbar
    
end

%delete waitbar
delete(hWait);
