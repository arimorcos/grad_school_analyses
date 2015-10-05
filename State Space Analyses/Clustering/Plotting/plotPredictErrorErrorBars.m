function handles = plotPredictErrorErrorBars(folder,fileStr,nBins)
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
if nargin < 3 || isempty(nBins)
    nBins = 10;
end

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

%% calculate significance 

%sum real differences across all datasets
totalSummedDiff = sum(cellfun(@(x) x.realSummedDiff,out));

%sum shuffled differences across all datasets 
shuffledDiff = cellfun(@(x) x.shuffledSummedDiff',out,'uniformoutput',false);
totalShuffleDiff = sum(cat(1,shuffledDiff{:}));

%get pvalue 
pVal = getPValFromShuffle(totalSummedDiff, totalShuffleDiff);

%display 
fprintf('P value <= %.3f \n', pVal);

%% get values and bin

totalErrorRate = mean(cellfun(@(x) x.totalErrorRate,out));
fracError = nan(nFiles,nBins);

for file = 1:nFiles
    
    %get error count and unique count 
    errorCount = out{file}.errorCount;
    uniqueCount = out{file}.uniqueCount;
    
    %get frac
    fileFracError = errorCount./uniqueCount;
    [~,sortOrder] = sort(fileFracError);
    errorCount = errorCount(sortOrder);
    uniqueCount = uniqueCount(sortOrder);
    
    %bin
    nClusters = length(errorCount);
    edges = round(linspace(1,nClusters,nBins+1));
    
    %average across each 
    for bin = 1:nBins
        binError = sum(errorCount(edges(bin):edges(bin+1)));
        binUnique = sum(uniqueCount(edges(bin):edges(bin+1)));
        fracError(file,bin) = binError/binUnique;
    end    
    
end

%% plot
handles.fig = figure;
handles.ax = axes;

%hold
hold(handles.ax,'on');

meanVals = mean(fracError);
semVals = calcSEM(fracError);
xVals = 1:nBins;
errH = shadedErrorBar(xVals,meanVals,semVals);
color = [0    0.4470    0.7410];
errH.mainLine.Color = color;
errH.patch.FaceColor = color;
errH.patch.FaceAlpha = 0.3;
errH.edge(1).Color = color;
errH.edge(2).Color = color;

%plot chance line 
chanceH = line([1 nBins],[totalErrorRate, totalErrorRate]);
chanceH.Color = 'k';
chanceH.LineStyle = '--';

%set axis to square
axis(handles.ax,'square');

%label axes
handles.ax.XLabel.String = 'Binned cluster number';
handles.ax.YLabel.String = 'Probability of incorrect behavioral choice';
handles.ax.XLabel.FontSize = 30;
handles.ax.YLabel.FontSize = 30;
handles.ax.FontSize = 20;
handles.ax.XTick = 1:nBins;
handles.ax.XLim = [1 nBins];

%maximize
beautifyPlot(handles.fig, handles.ax);

