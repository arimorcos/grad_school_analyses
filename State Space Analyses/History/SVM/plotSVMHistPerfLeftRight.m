function figH = plotSVMHistPerfLeftRight(leftPerf,rightPerf,shufflePerfLeft,...
    shufflePerfRight,mode,confInt)
%plotSVMHistPerf.m Plots SVM history performance
%
%INPUTS
%perf - svm performance as a fraction or nPerfVals x nSeg array of accuracy
%shufflePerf - nShuffle x nSeg array of shuffle accuracy 
%confInt - confidence intervals
%
%OUTPUTS
%figH - figure handle
%
%ASM 12/14

if nargin < 5 || isempty(mode)
    mode = 'svm';
end

if nargin < 6 || isempty(confInt) 
    confInt = 95;
end

%create figure
figH = figure;
axH = axes;

%get nSeg
if size(leftPerf,1) > 1
    nSeg = sum(~all(isnan(leftPerf)));
    shufflePerfLeft = shufflePerfLeft(:,~all(isnan(leftPerf)));
    shufflePerfLeft = shufflePerfLeft(~isnan(shufflePerfLeft(:,1)),:);    
    shufflePerfRight = shufflePerfRight(:,~all(isnan(rightPerf)));
    shufflePerfRight = shufflePerfRight(~isnan(shufflePerfRight(:,2)),:);
    leftPerf = leftPerf(:,~all(isnan(leftPerf)));
    leftPerf = leftPerf(~all(isnan(leftPerf),2),:);
    rightPerf = rightPerf(:,~all(isnan(rightPerf)));
    rightPerf = rightPerf(~all(isnan(rightPerf),2),:);
else
    nSeg = sum(isnan(leftPerf));
    shufflePerfLeft = shufflePerfLeft(:,~isnan(leftPerf));
    shufflePerfRight = shufflePerfRight(:,~isnan(leftPerf));
    leftPerf = leftPerf(:,~isnan(leftPerf));
    rightPerf = rightPerf(:,~isnan(rightPerf));
end

%calculate percentiles
percBoundsLeft = [(100 - confInt)/2 (100 - (100-confInt)/2)];
shufflePercLeft = prctile(shufflePerfLeft,percBoundsLeft);
percBoundsRight = [(100 - confInt)/2 (100 - (100-confInt)/2)];
shufflePercRight = prctile(shufflePerfRight,percBoundsRight);

%convert perc to diff from 0.5 
shufflePercLeft = flipud(abs(repmat(median(shufflePerfLeft),2,1) - shufflePercLeft));
shufflePercRight = flipud(abs(repmat(median(shufflePerfLeft),2,1) - shufflePercRight));

%hold on
hold on;

%plot performance 
if size(leftPerf,1) > 1 %if multiple perf vals
    if nSeg > 1
        perfPlotLeft = errorbar(0:nSeg-1,mean(leftPerf),std(leftPerf));
        perfPlotLeft.LineWidth = 2;
        perfPlotLeft.Color = 'b';
        perfPlotRight = errorbar(0:nSeg-1,mean(rightPerf),std(rightPerf));
        perfPlotRight.LineWidth = 2;
        perfPlotRight.Color = 'r';
    else
        perfPlotLeft = plot(0,leftPerf(:,1));
        perfPlotLeft.MarkerFaceColor = 'b';
        perfPlotLeft.MarkerEdgeColor = 'b';
        perfPlotRight = plot(0,rightPerf(:,1));
        perfPlotRight.MarkerFaceColor = 'r';
        perfPlotRight.MarkerEdgeColor = 'r';
    end
else
    if nSeg > 1
        perfPlotLeft = plot(0:nSeg-1,leftPerf);
        perfPlotLeft.LineWidth = 2;
        perfPlotLeft.Color = 'b';
        perfPlotRight = plot(0:nSeg-1,rightPerf);
        perfPlotRight.LineWidth = 2;
        perfPlotRight.Color = 'r';
    else
        perfPlotLeft = scatter(0,leftPerf(1));
        perfPlotLeft.MarkerFaceColor = 'b';
        perfPlotLeft.MarkerEdgeColor = 'b';
        perfPlotRight = scatter(0,rightPerf(1));
        perfPlotRight.MarkerFaceColor = 'r';
        perfPlotRight.MarkerEdgeColor = 'r';
    end
end
   

%plot shaded error bar 
if nSeg > 1
    shufflePlotLeft = shadedErrorBar(0:nSeg-1,nanmedian(shufflePerfLeft),shufflePercLeft,'-b');
    shufflePlotLeft.patch.FaceAlpha = 0.5;
    shufflePlotRight = shadedErrorBar(0:nSeg-1,nanmedian(shufflePerfRight),shufflePercRight,'-r');
    shufflePlotRight.patch.FaceAlpha = 0.5;
else
    shufflePlotLeft = errorbar(0,median(shufflePerfLeft),shufflePercLeft(1,1),shufflePercLeft(2,1));
    shufflePlotLeft.Color = 'b';
    shufflePlotLeft.Marker = 'o';
    shufflePlotLeft.MarkerFaceColor = 'b';
    shufflePlotRight = errorbar(0,median(shufflePerfRight),shufflePercRight(1,1),shufflePercRight(2,1));
    shufflePlotRight.Color = 'r';
    shufflePlotRight.Marker = 'o';
    shufflePlotRight.MarkerFaceColor = 'r';
end

%set axes 
axH.XLabel.String = 'Number of segments previous to current segment';
axH.XLabel.FontSize = 30;
axH.YLabel.FontSize = 30;
axH.FontSize = 20;
axH.XTick = 0:nSeg-1;
switch mode
    case 'svm'
        axH.YLim = [0 100];
        axH.YLabel.String = 'SVM Accuracy';
    case 'info'
        axH.YLabel.String = 'Mutual information (bits)';
end
if nSeg > 1 
    axH.XLim = [0 nSeg-1];
else
    axH.XLim = [-0.5 0.5];
end
legend([perfPlotLeft,perfPlotRight,shufflePlotLeft.patch,shufflePlotRight.patch],...
    {'Final Segment is Left','Final Segment is Right','Left Shuffle','Right Shuffle'},...
    'Location','Best');

