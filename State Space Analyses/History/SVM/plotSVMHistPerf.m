function figH = plotSVMHistPerf(perf,shufflePerf,confInt)
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

if nargin < 3 || isempty(confInt) 
    confInt = 95;
end

%create figure
figH = figure;
axH = axes;

%get nSeg
if size(perf,1) > 1
    nSeg = sum(~all(isnan(perf)));
    shufflePerf = shufflePerf(:,~all(isnan(perf)));
    perf = perf(:,~all(isnan(perf)));
    perf = perf(~all(isnan(perf),2),:);
else
    nSeg = sum(~isnan(perf));
    shufflePerf = shufflePerf(:,~isnan(perf));
    perf = perf(:,~isnan(perf));
end


%calculate percentiles
percBounds = [(100 - confInt)/2 (100 - (100-confInt)/2)];
shufflePerc = prctile(shufflePerf,percBounds);

%convert perc to diff from 0.5 
shufflePerc = flipud(abs(repmat(nanmedian(shufflePerf),2,1) - shufflePerc));

%plot performance 
if size(perf,1) > 1 %if multiple perf vals
    if nSeg > 1
        perfPlot = errorbar(0:nSeg-1,mean(perf),std(perf));
        perfPlot.LineWidth = 2;
        perfPlot.Color = 'b';
    else
        perfPlot = errorbar(0,mean(perf(:,1)),std(perf(:,1)));
        perfPlot.MarkerFaceColor = 'b';
        perfPlot.MarkerEdgeColor = 'b';
    end
else
    if nSeg > 1
        perfPlot = plot(0:nSeg-1,perf);
        perfPlot.LineWidth = 2;
        perfPlot.Color = 'b';
    else
        perfPlot = scatter(0,perf(1));
        perfPlot.MarkerFaceColor = 'b';
        perfPlot.MarkerEdgeColor = 'b';
    end
end
    

%hold on
hold on;

%plot shaded error bar 
if nSeg > 1
    shufflePlot = shadedErrorBar(0:nSeg-1,nanmedian(shufflePerf),shufflePerc,'-r');
    shufflePlot.patch.FaceAlpha = 0.5;
else
    shufflePlot = errorbar(0,nanmedian(shufflePerf),shufflePerc(1,1),shufflePerc(2,1));
    shufflePlot.Color = 'r';
    shufflePlot.Marker = 'o';
    shufflePlot.MarkerFaceColor = 'r';
end

%set axes 
axH.XLabel.String = 'Number of segments previous to current segment';
axH.XLabel.FontSize = 30;
axH.YLabel.String = 'SVM Accuracy';
axH.YLabel.FontSize = 30;
axH.FontSize = 20;
axH.XTick = 0:nSeg-1;
axH.YLim = [0 100];
if nSeg > 1 
    axH.XLim = [0 nSeg-1];
else
    axH.XLim = [-0.5 0.5];
end

