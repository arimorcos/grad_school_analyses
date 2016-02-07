function handles = plotMultiplePredictErrorDistribution(folder,fileStr)
%plotPredictErrorErrorBars.m Plots multiple clustered behavioral
%distributions from folder with error bars
%
%INPUTS
%folder - path to folder
%fileStr - string to match files to
%
%OUTPUTS
%handles - structure of handles
%
%ASM 10/15

showCDF = true;
nBins = 50;

%get list of files in folder
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array
nFiles = length(matchFiles);
out = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    out{fileInd} = currFileData.out;
end

%% get distributions
realErrorRates = [];
shuffleErrorRates = [];
for file = 1:nFiles
    
    tempReal = out{file}.errorCount./out{file}.uniqueCount;
    tempShuffle = out{file}.shuffleErrorCount(:,1)./out{file}.uniqueCount;
    
    realErrorRates = cat(1,realErrorRates,tempReal);
    shuffleErrorRates = cat(1,shuffleErrorRates, tempShuffle);
    
end

%% plot
figH = figure;
axH = axes;

%hold
hold(axH,'on');

minVal = min(cat(1,realErrorRates,shuffleErrorRates));
maxVal = max(cat(1,realErrorRates,shuffleErrorRates));

binEdges = linspace(minVal,maxVal,nBins+1);
xVals = binEdges(1:end) + mean(diff(binEdges));

%shaded version

%outline version
smooth = false;
if showCDF
    histRealCounts = [0, histcounts(realErrorRates, binEdges)];
    histShuffleCounts = [0, histcounts(shuffleErrorRates, binEdges)];
    cdfReal = cumsum(histRealCounts)/sum(histRealCounts);
    cdfShuffle = cumsum(histShuffleCounts)/sum(histShuffleCounts);
    histReal = plot(xVals, cdfReal, 'LineWidth', 2);
    histShuffle = plot(xVals, cdfShuffle, 'LineWidth', 2);
else
    histReal = histoutline(realErrorRates,binEdges,smooth,'Normalization','probability');
    histShuffle = histoutline(shuffleErrorRates,binEdges,smooth,'Normalization','probability');
    uistack(histReal,'top');
    histReal.LineWidth = 2;
    histShuffle.LineWidth = 2;
end
histShuffle.Color = [0.7 0.7 0.7];

axH.XLim = [minVal maxVal];

%beautify
beautifyPlot(figH,axH);

%label
axH.XLabel.String = 'Error rate';
if showCDF
    axH.YLabel.String = 'Cumulative fraction of clusters';
else
    axH.YLabel.String = 'Fraction of clusters';
end

%add legend
legH = legend([histReal, histShuffle],{'Real','Shuffled'},'Location','NorthEast');
if showCDF
    legH.Location = 'SouthEast';
end

% [~,pVal] = kstest2(realErrorRates,shuffleErrorRates);

% fprintf('P value: %.3e\n',pVal);


