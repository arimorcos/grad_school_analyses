function plotWithinVsAcrossCategoryDistance(segIntraDist, segInterDist)
%plotWithinVsAcrossCategoryDistance.m Plots output of 
%getWithinVsAcrossCategoryDistance in grouped bar plot with statistics for
%each internal comparison
%
%INPUTS
%segIntraDist - 1 x nSeg cell array fo distances within a category 
%segInterDist - 1 x nSeg cell array of distances across categories
%
%ASM 2/15

%calculate mean and sem 
meanIntraDist = cell2mat(cellfun(@mean,segIntraDist,'UniformOutput',false));
semIntraDist = cell2mat(cellfun(@calcSEM,segIntraDist,'UniformOutput',false));

meanInterDist = cell2mat(cellfun(@mean,segInterDist,'UniformOutput',false));
semInterDist = cell2mat(cellfun(@calcSEM,segInterDist,'UniformOutput',false));

%concatenate for bar plot
barErr = cat(2,semIntraDist', semInterDist');
barMean = cat(2,meanIntraDist', meanInterDist');

%strip out nans 
segLabels = 1:length(meanIntraDist);
segLabels = segLabels(~isnan(barErr(:,1)));
barErr = barErr(~isnan(barErr(:,1)),:);
barMean = barMean(~isnan(barMean(:,1)),:);

%calculate statistics 
p = nan(size(segLabels));
for seg = 1:length(segLabels)
   [~,p(seg)] = ttest2(segIntraDist{segLabels(seg)},segInterDist{segLabels(seg)});
end

%assert that not empty
aassert(~isempty(barErr),'No distances match condition');

%create figure 
figH = figure; 
axH = axes;

%show bar plot 
[barH, errH] = barwitherr(barErr, barMean);
barH(1).FaceColor = 'b';
barH(2).FaceColor = 'r';
set(errH(:),'LineWidth',2)

%add significance
xLocations = (1:length(p))';
xLocations = num2cell(cat(2,xLocations - 0.1, xLocations + 0.1),2);
sigstar(xLocations,p');

%label 
axH.XLabel.String = 'Segment Number';
axH.YLabel.String = 'Mean Euclidean Distance';
axH.FontSize = 20;
axH.XTickLabel = segLabels;
legH = legend({'Within Category Distance','Across Category Distance'},...
    'Location','NorthWest');