function calculateOverlappingSelectivity(whichOverlap,whichNonOverlap,acc)
%calculateOverlappingSelectivity.m Calculates the mean selectivity of
%neurons which overlap vs. those which don't overlap and calculates
%significance between the two 
%
%INPUTS
%whichOverlap - nPoints x 1 cell array of which neurons overlap 
%whichNonOverlap - nPoints x 1 cell array of which neurons don't overlap
%acc - nNeurons x nBins array of left-right accuracy 
%
%OUPUTS
%
%ASM 5/15

pointLabels = {'Maze Start','Segment 1','Segment 2','Segment 3','Segment 4',...
    'Segment 5','Segment 6','Early Delay','Late Delay','Turn'};


%get nPoints
nPoints = length(whichOverlap);

%loop through each point and get overlapping and non-overlapping neurons 
overlapNeurons = cell(nPoints,1);
nonOverlapNeurons = cell(nPoints,1);
for point = 1:nPoints
    
    %get neurons which overlap 
    overlapNeurons{point} = unique(cat(1,whichOverlap{point}{:}));
    
    %get neurons which don't overlap 
    nonOverlapNeurons{point} = unique(cat(1,whichNonOverlap{point}{:}));
    
    %remove neurons which overlap in some other cluster 
    removeInd = ismember(nonOverlapNeurons{point},overlapNeurons{point});
    nonOverlapNeurons{point}(removeInd) = [];
end

%loop through each point and get peak accuracy for each group 
overlapPeakAcc = cell(nPoints,1);
nonOverlapPeakAcc = cell(nPoints,1);
pVal = nan(nPoints,1);
for point = 1:nPoints
    overlapPeakAcc{point} = max(acc(overlapNeurons{point},:),[],2);
    nonOverlapPeakAcc{point} = max(acc(nonOverlapNeurons{point},:),[],2);
    
    %get significance 
    [~,pVal(point)] = ttest2(overlapPeakAcc{point},nonOverlapPeakAcc{point});
    
end

%get means 
meanOverlapPeakAcc = cellfun(@mean,overlapPeakAcc);
semOverlapPeakAcc = cellfun(@calcSEM,overlapPeakAcc);
meanNonOverlapPeakAcc = cellfun(@mean,nonOverlapPeakAcc);
semNonOverlapPeakAcc = cellfun(@calcSEM,nonOverlapPeakAcc);

%% plot 
figH = figure; 
axH = axes;
hold(axH,'on');

%plot overlap 
overH = shadedErrorBar(1:nPoints,meanOverlapPeakAcc,semOverlapPeakAcc,'b');
nonOverH = shadedErrorBar(1:nPoints,meanNonOverlapPeakAcc,semNonOverlapPeakAcc,'r');

%change transparency
overH.patch.FaceAlpha = 0.4;
nonOverH.patch.FaceAlpha = 0.4;

%add significance 
peakOverY = meanOverlapPeakAcc + semOverlapPeakAcc;
peakNonOverY = meanNonOverlapPeakAcc + semNonOverlapPeakAcc;
peakY = max(peakOverY,peakNonOverY);
for point = 1:nPoints
    if pVal(point) < 0.001
        textH = text(point,peakY(point) + 0.5,'***');
    elseif pVal(point) < 0.01
        textH = text(point,peakY(point) + 0.5,'*');
    elseif pVal(point) < 0.05
        textH = text(point,peakY(point) + 0.5,'*');
    else
%         textH = text(point,peakY(point) + 0.5,'N.S.');
continue;
    end
    textH.VerticalAlignment = 'Bottom';
    textH.HorizontalAlignment = 'Center';
    textH.FontSize = 30;
end

%change to square axis 
axis(axH,'square');
axH.FontSize = 20;
axH.XTickLabel = pointLabels;
axH.XTickLabelRotation = -45;
axH.LabelFontSizeMultiplier = 1.5;
axH.YLabel.String = 'Mean Peak Accuracy';
axH.YLim = [50 100];
axH.XTick = 1:nPoints;

%add legend 
legH = legend([overH.mainLine,nonOverH.mainLine],{'Overlapping neurons',...
    'Non-overlapping neurons'},'Location','SouthEast');