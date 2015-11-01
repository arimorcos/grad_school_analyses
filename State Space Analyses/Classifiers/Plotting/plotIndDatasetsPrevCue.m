function [acc, shuffleAcc] = plotIndDatasetsPrevCue(folder,fileStr)
%plotIndDatasetsPrevCue.m Plots overlapping histograms for individual
%datasets along with stats. Can plot several forms: A cdf/histogram of
%individual datasets, a cdf/histogram of all datsets grouped together, or
%an accuracy vs. shuffle plot 
%
%INPUTS
%folder - path to folder
%fileStr - string to match files to
%
%OUTPUTS
%handles - structure of handles
%
%ASM 10/15

showCDF = ~true;
groupAll = ~true;
showAcc = true;

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

%% plot all datasets
if groupAll
    
    allInter = cellfun(@(x) x.allInter,out,'uniformoutput',false);
    allInter = cat(1,allInter{:});
    
    allIntra = cellfun(@(x) x.allIntra,out,'uniformoutput',false);
    allIntra = cat(1,allIntra{:});
    
    %create figure
    figH = figure;
    axH = axes;
    hold(axH,'on');
    
    minVal = min(cat(1,allInter,allIntra));
    maxVal = max(cat(1,allInter,allIntra));
    nBins = 100;
    binEdges = linspace(minVal,maxVal,nBins+1);
    %     xVals = [0, binEdges(1:end-1) + mean(diff(binEdges))];
    xVals = binEdges(1:end) + mean(diff(binEdges));
    
    if showCDF
        histIntraCounts = [0, histcounts(allIntra, binEdges)];
        histInterCounts = [0, histcounts(allInter, binEdges)];
        cdfIntra = cumsum(histIntraCounts)/sum(histIntraCounts);
        cdfInter = cumsum(histInterCounts)/sum(histInterCounts);
        histIntra = plot(xVals, cdfIntra, 'LineWidth', 2);
        histInter = plot(xVals, cdfInter, 'LineWidth', 2);
    else
        smooth = false;
        histIntra = histoutline(allIntra,binEdges,smooth,'Normalization','probability');
        histInter = histoutline(allInter,binEdges,smooth,'Normalization','probability');
        uistack(histIntra,'top');
        histIntra.LineWidth = 2;
        histInter.LineWidth = 2;
    end
    
    %get significante
    [~,p] = kstest2(allIntra, allInter);
    fprintf('P value: %.4e\n',p);
    
    %beautify
    beautifyPlot(figH, axH);
    
    %label
    axH.XLabel.String = 'Correlation coefficient';
    axH.YLabel.String = 'Cumulative fraction of trial pairs';
    
    %legend
    legend([histIntra, histInter],{'Same previous cue','Different previous cues'},...
        'Location', 'SouthEast');
    
    %limits
    axH.XLim = [minVal maxVal];
    axH.YLim = [0 1];
    
    acc = [];
    shuffleAcc = [];
    return;
end

%% show accuracy

acc = nan(nFiles, 1);
shuffleAcc = cell(nFiles, 1);
accPVal = nan(nFiles,1);
for file = 1:nFiles
    %calculate accuracy
    acc(file) = sum(out{file}.allGuess == out{file}.allLabel)/length(out{file}.allLabel);
    
    %calculate shuffled accuracy
    shuffleAcc{file} = sum(out{file}.allGuessShuffle == out{file}.allLabelShuffle)/...
        length(out{file}.allLabel);
    
    %get acc pval
    accPVal(file) = getPValFromShuffle(acc(file), shuffleAcc{file});
end

%process shuffleAccuracy 
allShuffleAcc = cat(1,shuffleAcc{:});
allShuffleAcc = sort(allShuffleAcc);
meanShuffleAcc = mean(allShuffleAcc, 2);

%scale by 100
meanShuffleAcc = 100*meanShuffleAcc;
acc = 100*acc;

if showAcc
    
    figH = figure;
    axH = axes; 
    hold(axH,'on');
    
    %plot real accuracy 
    meanAcc = mean(acc);
    semAcc = calcSEM(acc);
    accError = line([1 1], [meanAcc - semAcc, meanAcc + semAcc]);
    accScatter = scatter(1,meanAcc);
    blue = lines(1);
    accScatter.Marker = 'o';
    accScatter.MarkerFaceColor = blue;
    accScatter.MarkerEdgeColor = blue;
    accScatter.SizeData = 150;
    accError.Color = blue;
    accError.LineWidth = 2;
    
    % plot shuffle accuracy 
    bounds = prctile(meanShuffleAcc, [0.5 99.5]);
    shuffleH = line([1 1], bounds);
    gray = repmat(0.7, 1, 3);
    shuffleH.Color = gray;
    shuffleH.LineWidth = 2;
    
    %add chance line 
    chanceH = line([0 2], [50 50]);
    chanceH.LineWidth = 2;
    chanceH.Color = 'k';
    chanceH.LineStyle = '--';
        
    %beautify 
    beautifyPlot(figH, axH);
    
    %label 
    axH.YLabel.String = 'Classification accuracy of previous cue';
    axH.YLim = [30 70];
    axH.XLim = [0 2];
    axH.XTick = [];
    
    %legend 
    legend([accScatter, shuffleH], {'Real', 'Shuffled'},...
        'Location','BestOutside');
    
    return;
end

%% plot individual datasets
nRows = 4;
nCol = 3;

figH = figure;

for file = 1:nFiles
    
    %axis
    axH = subplot(nRows, nCol, file);
    hold(axH,'on');
    
    minVal = min(cat(1,out{file}.allInter,out{file}.allIntra));
    maxVal = max(cat(1,out{file}.allInter,out{file}.allIntra));
    nBins = 100;
    binEdges = linspace(minVal,maxVal,nBins+1);
    xVals = [0, binEdges(1:end-1) + mean(diff(binEdges))];
    
    if showCDF
        histIntraCounts = [0, histcounts(out{file}.allIntra, binEdges)];
        histInterCounts = [0, histcounts(out{file}.allInter, binEdges)];
        cdfIntra = cumsum(histIntraCounts)/sum(histIntraCounts);
        cdfInter = cumsum(histInterCounts)/sum(histInterCounts);
        plotIntra = plot(xVals, cdfIntra, 'LineWidth', 2);
        plotInter = plot(xVals, cdfInter, 'LineWidth', 2);
    else
        smooth = false;
        histIntra = histoutline(out{file}.allIntra,binEdges,smooth,'Normalization','probability');
        histInter = histoutline(out{file}.allInter,binEdges,smooth,'Normalization','probability');
        uistack(histIntra,'top');
        histIntra.LineWidth = 2;
        histInter.LineWidth = 2;
    end
    
    %beautify
    beautifyPlot(figH, axH)
    
    %limits
    axH.XLim = [minVal maxVal];
    
    %calculate significance
    %     [~,p] = ttest2(out{file}.allIntra,out{file}.allInter);
    [~,p] = kstest2(out{file}.allIntra,out{file}.allInter);
    
    
    %plot
    textLow = text(axH.XLim(2)-0.02*range(axH.XLim),...
        axH.YLim(1) + 0.02*range(axH.YLim), sprintf('Dist pVal=%.3f',p));
    textLow.HorizontalAlignment = 'right';
    textLow.VerticalAlignment = 'bottom';
    textAcc = text(axH.XLim(2)-0.02*range(axH.XLim),...
        axH.YLim(1) + 0.1*range(axH.YLim), sprintf('Acc: %.3f, pVal=%.3f',...
        acc(file), accPVal(file)));
    textAcc.HorizontalAlignment = 'right';
    textAcc.VerticalAlignment = 'bottom';
end

scale_subplots(1.15);