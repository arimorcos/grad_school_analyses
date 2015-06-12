function plotClusteredBehavioralDistribution(in)
%plotClusteredBehavioralDistribution.m Plots output of cluster behavioral
%distribution 
%
%INPUTS
%in - output of clusterBehavioralDistribution.m 
%
%ASM 6/15

thresh = 5;
%filter clusters with fewer than thresh trials
keepInd = in.uniqueCount > thresh;
in.uniqueCount = in.uniqueCount(keepInd);
in.clusterVarCount = in.clusterVarCount(keepInd);
in.shuffleVarCount = in.shuffleVarCount(keepInd,:);

%get nClusters
nClusters = length(in.uniqueCount);

%calculate fractions
actualFraction = in.clusterVarCount./in.uniqueCount;
shuffleFraction = bsxfun(@rdivide,in.shuffleVarCount,in.uniqueCount);

%sort by actual fraction 
[actualFraction,sortOrder] = sort(actualFraction);
shuffleFraction = shuffleFraction(sortOrder,:);

%calculate 99% confidence intervals 
confInt = prctile(shuffleFraction,[0.5 99.5],2);
medianShuffle = median(shuffleFraction,2);
confInt = abs(bsxfun(@minus,confInt,medianShuffle));

%% plot 
figH = figure;
axH = axes;
hold(axH,'on');

%plot error 
errH = shadedErrorBar(1:nClusters,medianShuffle,confInt','r',0.2);

%plot actual 
scatH = scatter(1:nClusters,actualFraction,'filled');
scatH.MarkerFaceColor = 'b';
scatH.MarkerEdgeColor = 'b';
scatH.SizeData = 200;

%beautify 
beautifyPlot(figH,axH);

%labels 
axH.XLabel.String = 'Sorted Cluster #';
axH.YLabel.String = 'Fraction left turns';