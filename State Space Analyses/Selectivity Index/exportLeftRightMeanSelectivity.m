function exportLeftRightMeanSelectivity(dataCell,outFileName)
%exportLeftRightMeanSelectivity.m Exports a pdf containing every cell's
%left trials right trials, mean activity on left and right, and selectivity
%index
%
%INPUTS
%dataCell
%outFileName - path and file name of output
%
%ASM 1/14

%get imSub
imSub = getTrials(dataCell,'imaging.imData == 1');

%bin if necessary
if ~isfield(imSub{1}.imaging,'binnedDFFTraces')
    imSub = binFramesByYPos(imSub,15);
end

%get activity across all trials
% dFFTraces = thresholdTraces(dataCell{1}.imaging.completeDFFTrace,imSub,2);
dFFTraces = catBinnedTraces(imSub);

%get left/right trials
leftTrials = findTrials(imSub,'maze.crutchTrial==0;maze.numLeft==0,6;result.correct==1;result.leftTurn==1');
rightTrials = findTrials(imSub,'maze.crutchTrial==0;maze.numLeft==0,6;result.correct==1;result.leftTurn==0');

%get nCells 
nCells = size(dFFTraces,1);

%get subsets
leftTraces = dFFTraces(:,:,leftTrials);
rightTraces = dFFTraces(:,:,rightTrials);

%take mean
meanLeft = nanmean(leftTraces,3);
meanRight = nanmean(rightTraces,3);

%get std
stdLeft = nanstd(leftTraces,0,3);
stdRight = nanstd(rightTraces,0,3);

%get sem
semLeft = stdLeft/sqrt(sum(leftTrials));
semRight = stdRight/sqrt(sum(rightTrials));

%get selectivity
[selectivity,sig,~,bins] = leftRightSelectivity(dataCell,15,1e2);
sig = double(sig);
sig(sig==0) = nan;
sig(sig == 1) = 0;

%delete file if exists
if exist([outFileName,'.pdf'],'file')
    delete([outFileName,'.pdf']);
end

%create waitbar
hWait = waitbar(0,'Creating figures...');

%cycle through each cell and create figure
for i = 1:nCells % for each cell
    
    %create figure;
    figHandle = figure('Visible','off');
    
    %find min max of data
    leftData = squeeze(leftTraces(i,:,:))';
    rightData = squeeze(rightTraces(i,:,:))';
    minData = min(min(cat(1,leftData,rightData)));
    maxData = max(max(cat(1,leftData,rightData)));
    
    %create left trial plot
    subplot(2,2,1);
    imagesc(bins,1:sum(leftTrials),leftData,[minData maxData]);
    xlabel('Binned Position');
    ylabel('Trial #');
    axis square;
    colorbar;
    title('Left Trials');
    
    %create right trial plot
    subplot(2,2,3);
    imagesc(bins,1:sum(rightTrials),rightData,[minData maxData]);
    xlabel('Binned Position');
    ylabel('Trial #');
    axis square;
    colorbar;
    title('Right Trials');
    
    %create mean plot
    subplot(2,2,2);
    h1 = shadedErrorBar(bins,meanLeft(i,:),semLeft(i,:),'b');
    hold on;
    h2 = shadedErrorBar(bins,meanRight(i,:),semRight(i,:),'r');
    xlabel('Binned Position');
    ylabel('Mean dF/F +- SEM');
    legend([h1.mainLine h2.mainLine],'Left','Right','Location','NorthWest');
    title('Mean Activity');
    axis square;
    xlim([bins(1) bins(end)]);
    
    %create selectivity plot
    subplot(2,2,4);
    plot(bins,selectivity(i,:));
    ylim([-1 1]);
    ylabel('Selectivity Index');
    xlabel('Binned Position');
    title('Selectivity');
    axis square;
    hold on;
    plot(bins,sig(i,:),'k');
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