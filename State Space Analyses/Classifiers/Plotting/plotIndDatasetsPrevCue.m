function [acc, shuffleAcc] = plotIndDatasetsPrevCue(folder,fileStr)
%plotIndDatasetsPrevCue.m Plots overlapping histograms for individual
%datasets along with stats
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
groupAll = true;

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
    
    %beautify 
    beautifyPlot(figH, axH);
    
    keyboard;
    
    
    acc = [];
    shuffleAcc = [];
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
    
    %calculate accuracy 
    acc(file) = sum(out{file}.allGuess == out{file}.allLabel)/length(out{file}.allLabel);
    
    %calculate shuffled accuracy 
    shuffleAcc{file} = sum(out{file}.allGuessShuffle == out{file}.allLabelShuffle)/...
        length(out{file}.allLabel);
    
    %get acc pval
    accP = getPValFromShuffle(acc(file), shuffleAcc{file});
    
    %plot
    textLow = text(axH.XLim(2)-0.02*range(axH.XLim),...
        axH.YLim(1) + 0.02*range(axH.YLim), sprintf('Dist pVal=%.3f',p));
    textLow.HorizontalAlignment = 'right';
    textLow.VerticalAlignment = 'bottom';
    textAcc = text(axH.XLim(2)-0.02*range(axH.XLim),...
        axH.YLim(1) + 0.1*range(axH.YLim), sprintf('Acc: %.3f, pVal=%.3f',...
        acc, accP));
    textAcc.HorizontalAlignment = 'right';
    textAcc.VerticalAlignment = 'bottom';
end

scale_subplots(1.15);