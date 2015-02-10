function plotPooledDistances(separateLeftRight, nBack, varargin)
%plotPooledDistances.m Plots pooled distances
%
%INPUTS
%separateLeftRight - should separate or not. If true, intraLeft,
%intraRight, interLeft, interRight. If false, intraAll, interAll.
%
%
%ASM 1/15

%process varargin
varargin = varargin{1};
if separateLeftRight
    intraLeft = varargin{1};
    intraRight = varargin{2};
    interLeft = varargin{3};
    interRight = varargin{4};
else 
    intraAll = varargin{1};
    interAll = varargin{2};
end

%create figure
figure;

%plot mean +- std 
ax1 = subplot(2,1,1);
errPlot = errorbar([mean(intraAll{nBack}),mean(interAll{nBack})],[std(interAll{nBack}),std(intraAll{nBack})]);
errPlot.LineStyle = 'none';
errPlot.Marker = 'o';
ax1.XTick = [1 2];
ax1.XTickLabel = {'Intra', 'Inter'};
axis(ax1,'square');
ax1.YLabel.String = 'Euclidean Distance';

%calculate p-value 
[~,p] = ttest2(intraAll{nBack},interAll{nBack});
pText = text(1.5, mean(ax1.YLim),sprintf('p = %.4f',p));
pText.HorizontalAlignment = 'Center';
pText.VerticalAlignment = 'Middle';
pText.FontWeight = 'Bold';

%plot histogram
ax2 = subplot(2,1,2);
histogram(intraAll{nBack},100,'FaceColor','b','FaceAlpha',0.25);
hold on;
histogram(interAll{nBack},100,'FaceColor','r','FaceAlpha',0.25);
legend({'Intra','Inter'});
ax2.YLabel.String = 'Count';
ax2.XLabel.String = 'Distance';
