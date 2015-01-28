function exportLeftRightMeanSelectivity6051(dataCell,outFileName)
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
left60Trials = findTrials(imSub,'maze.crutchTrial==0;maze.numLeft==0,6;result.correct==1;result.leftTurn==1');
right60Trials = findTrials(imSub,'maze.crutchTrial==0;maze.numLeft==0,6;result.correct==1;result.leftTurn==0');
left51Trials = findTrials(imSub,'maze.crutchTrial==0;maze.numLeft==1,5;result.correct==1;result.leftTurn==1');
right51Trials = findTrials(imSub,'maze.crutchTrial==0;maze.numLeft==1,5;result.correct==1;result.leftTurn==0');

%get nCells 
nCells = size(dFFTraces,1);

%get subsets
left60Traces = dFFTraces(:,:,left60Trials);
right60Traces = dFFTraces(:,:,right60Trials);
left51Traces = dFFTraces(:,:,left51Trials);
right51Traces = dFFTraces(:,:,right51Trials);

%take mean
meanLeft60 = nanmean(left60Traces,3);
meanRight60 = nanmean(right60Traces,3);
meanLeft51 = nanmean(left51Traces,3);
meanRight51 = nanmean(right51Traces,3);

%get std
stdLeft60 = nanstd(left60Traces,0,3);
stdRight60 = nanstd(right60Traces,0,3);
stdLeft51 = nanstd(left51Traces,0,3);
stdRight51 = nanstd(right51Traces,0,3);

%get sem
semLeft60 = stdLeft60/sqrt(sum(left60Trials));
semRight60 = stdRight60/sqrt(sum(right60Trials));
semLeft51 = stdLeft51/sqrt(sum(left51Trials));
semRight51 = stdRight51/sqrt(sum(right51Trials));

%get selectivity
[selectivity60,sig60,~,bins] = leftRightSelectivity(dataCell,15,1e2,[],...
    {'maze.crutchTrial==0;result.correct==1;maze.numLeft==0,6;result.leftTurn==1'...
     'maze.crutchTrial==0;result.correct==1;maze.numLeft==0,6;result.leftTurn==0'});
sig60 = double(sig60);
sig60(sig60==0) = nan;
sig60(sig60 == 1) = 0;

[selectivity51,sig51,~,~] = leftRightSelectivity(dataCell,15,1e2,[],...
    {'maze.crutchTrial==0;result.correct==1;maze.numLeft==1,5;result.leftTurn==1'...
    'maze.crutchTrial==0;result.correct==1;maze.numLeft==1,5;result.leftTurn==0'});
sig51 = double(sig51);
sig51(sig51==0) = nan;
sig51(sig51 == 1) = 0;

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
    leftData60 = squeeze(left60Traces(i,:,:))';
    rightData60 = squeeze(right60Traces(i,:,:))';
    leftData51 = squeeze(left51Traces(i,:,:))';
    rightData51 = squeeze(right51Traces(i,:,:))';
    minData = min(min(cat(1,leftData60,rightData60,leftData51,rightData51)));
    maxData = max(max(cat(1,leftData60,rightData60,leftData51,rightData51)));
    
    %create left trial plot 60
    subplot(3,2,1);
    imagesc(bins,1:sum(left60Trials),leftData60,[minData maxData]);
    xlabel('Binned Position');
    ylabel('Trial #');
    axis square;
    colorbar;
    title('Left 6-0 Trials');
    
    %create right trial plot 60
    subplot(3,2,2);
    imagesc(bins,1:sum(right60Trials),rightData60,[minData maxData]);
    xlabel('Binned Position');
    ylabel('Trial #');
    axis square;
    colorbar;
    title('Right 6-0 Trials');
    
    %create left trial plot 60
    subplot(3,2,3);
    imagesc(bins,1:sum(left51Trials),leftData51,[minData maxData]);
    xlabel('Binned Position');
    ylabel('Trial #');
    axis square;
    colorbar;
    title('Left 5-1 Trials');
    
    %create right trial plot 60
    subplot(3,2,4);
    imagesc(bins,1:sum(right51Trials),rightData51,[minData maxData]);
    xlabel('Binned Position');
    ylabel('Trial #');
    axis square;
    colorbar;
    title('Right 5-1 Trials');
    
    %create mean plot
    subplot(3,2,5);
    h1 = shadedErrorBar(bins,meanLeft60(i,:),semLeft60(i,:),'b');
    hold on;
    h2 = shadedErrorBar(bins,meanRight60(i,:),semRight60(i,:),'r');
    h3 = shadedErrorBar(bins,meanLeft51(i,:),semLeft51(i,:),'k');
    h4 = shadedErrorBar(bins,meanRight51(i,:),semRight51(i,:),'g');
    
    xlabel('Binned Position');
    ylabel('Mean dF/F +- SEM');
    axis square;
    pos = get(gca,'position');
    legend([h1.mainLine h2.mainLine h3.mainLine h4.mainLine],...
        'Left 6-0','Right 6-0','Left 5-1','Right 5-1','Location',...
        [pos(3) + 0.05 pos(2) + 0.5*(pos(4) - pos(2)) 0.3*pos(3) pos(4)-pos(2)]);
    title('Mean Activity');

    xlim([bins(1) bins(end)]);
    
    %create selectivity plot
    subplot(3,2,6);
    plot(bins,selectivity60(i,:),'b');
    hold on;
    plot(bins,selectivity51(i,:),'r');
    plot(bins,sig60(i,:)-0.025,'k');
    plot(bins,sig51(i,:)+0.025,'g');
    ylim([-1 1]);
    ylabel('Selectivity Index');
    xlabel('Binned Position');
    title('Selectivity');
    axis square;
    pos = get(gca,'position');
    legend('6-0 SI','5-1 SI','6-0 sig','5-1 sig','Location',...
        [pos(3) + 0.05 pos(2) + 0.5*(pos(4) - pos(2)) 0.3*pos(3) pos(4)-pos(2)]);
    
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