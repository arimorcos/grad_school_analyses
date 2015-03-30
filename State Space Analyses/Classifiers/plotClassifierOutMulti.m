function figH = plotClassifierOutMulti(folder, match)
%plotClassifierOutMulti.m Plots multiple files classifier outputs
%
%INPUTS
%folder - folder containing data
%match - match string
%
%OUTPUTS
%figH - figure handle
%
%ASM 3/15

confInt = 95;
segRanges = 0:80:480;

% load in data
[file, yPosBins, accuracy, shuffleAccuracy] = loadAndCatData(folder, match,...
    {'yPosBins','accuracy','shuffleAccuracy'});

%create figure
figH = figure;
axH = axes;
hold(axH,'on');
colors = distinguishable_colors(length(file));
accPlot = gobjects(length(file),1);

for fileInd = 1:length(file)
    
    %plot accuracy
    accPlot(fileInd) = plot(yPosBins{fileInd}(2:end-1), accuracy{fileInd}(2:end-1));
    accPlot(fileInd).Color = colors(fileInd,:);
    accPlot(fileInd).LineWidth = 2;
    
    %plot shuffle
    if ~isempty(shuffleAccuracy{fileInd})
        
        %determine confidence interval range
        lowConf = (100 - confInt)/2;
        highConf = 100 - lowConf;
        
        %get confidence intervals
        shuffleMedian = median(shuffleAccuracy{fileInd});
        confidenceIntervals = prctile(shuffleAccuracy{fileInd},[highConf,lowConf]);
        confidenceIntervals = abs(bsxfun(@minus,confidenceIntervals,shuffleMedian));
        
        %plot shuffle
        shuffleH = plot(yPosBins{fileInd}(2:end-1), shuffleMedian(2:end-1) +...
            confidenceIntervals(1,2:end-1));
%         shuffleH = shadedErrorBar(yPosBins,shuffleMedian,confidenceIntervals);
%         shuffleH.patch.FaceAlpha = 0.2;
%         shuffleH.patch.FaceColor = 'r';
%         shuffleH.mainLine.Color = 'r';
        shuffleH.Color = colors(fileInd,:);
        shuffleH.LineStyle = ':';
        shuffleH.LineWidth = 2;
    end
    
end

%plot chance line
line([-1000 10000],[50 50 ],'Color','k','LineStyle','--');

%set limits
axH.XLim = [min(cat(2,yPosBins{:})) max(cat(2,yPosBins{:}))];
axH.YLim = [0 100];

%label axes
axH.XLabel.String = 'Maze Position (binned)';
axH.YLabel.String = 'Classifier Accuracy';

%set axes overall size
axH.FontSize = 20;

%add on segment dividers
for i = 1:length(segRanges)
    line(repmat(segRanges(i),1,2),[0 100],'Color',[34 139 34]/255,'LineStyle','--');
end

% add legend 
legend(accPlot,cat(1,file{:}),'Location','Best');

