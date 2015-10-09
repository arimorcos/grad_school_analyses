function plotAllIndNeuronClusterTurnAddRegression(folder,fileStr)
%plotAllIndNeuronClusterTurnAddRegression.m Plots all individual neuron
%turn vs cluster regression
%
%INPUTS 
%folder - path to folder 
%fileStr - string to match files to 
%
%OUTPUTS
%handles - structure of handles 
%
%ASM 7/15

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%get nFiles
nFiles = length(matchFiles);

%loop through each file and create array 
out = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    out{fileInd} = currFileData.out;
end

%% combine across all datasets 
turnR2 = cellfun(@(x) x.turnR2,out,'uniformoutput',false);
turnR2 = cat(1,turnR2{:});

bothR2 = cellfun(@(x) x.bothR2,out,'uniformoutput',false);
bothR2 = cat(1,bothR2{:});

shuffleR2 = cellfun(@(x) x.shuffleR2,out,'uniformoutput',false);
shuffleR2 = cat(1,shuffleR2{:});

%% calculate significance

%crop off testShuffle
testShuffleR2 = shuffleR2(:,1);
shuffleR2 = shuffleR2(:,2:end);

%get differences 
diffR2 = bothR2 - turnR2;
shuffleDiffR2 = bsxfun(@minus, shuffleR2, turnR2);
testDiffR2 = testShuffleR2 - turnR2;

%get nNeurons
nNeurons = length(diffR2);

neuronPVal = nan(nNeurons, 1);
shufflePVal = nan(nNeurons, 1);
for neuron = 1:nNeurons
    neuronPVal(neuron) = getPValFromShuffle(diffR2(neuron),shuffleDiffR2(neuron,:));
    shufflePVal(neuron) = getPValFromShuffle(testDiffR2(neuron),shuffleDiffR2(neuron,:));
end

%get significant neurons 
neuronSig = neuronPVal < 0.05;

%% plot 
markSize = 50;

figH = figure;
axH = axes;
hold(axH, 'on');
axH.XLim = [0 1];
axH.YLim = [0 1];

%add unity line
unity = line([0 1], [0 1]);
unity.Color = 'k';
unity.LineStyle = '--';
unity.LineWidth = 2;

% scatter the not-significant neurons 
scatNotSig = scatter(turnR2(~neuronSig), bothR2(~neuronSig));
gray = repmat(0.7, 1, 3);
scatNotSig.SizeData = markSize;
scatNotSig.MarkerFaceColor = gray;
scatNotSig.MarkerEdgeColor = gray;

%scatter the significant neurons 
blue = lines(1);
scatSig = scatter(turnR2(neuronSig), bothR2(neuronSig));
scatSig.SizeData = markSize;
scatSig.MarkerFaceColor = blue;
scatSig.MarkerEdgeColor = blue;

%beautify
beautifyPlot(figH, axH);

%label 
axH.XLabel.String = 'Turn adjusted R^{2}';
axH.YLabel.String = 'Turn + cluster adjusted R^{2}';
axH.YTick = 0:0.2:1;
axH.XTick = 0:0.2:1;

%legend 
legend([scatSig, scatNotSig],{'p < 0.05','p > 0.05'},...
    'Location','SouthEast');

%% plot distributions 
figH = figure;
axH = axes;
hold(axH, 'on');

% define bins 
nBins = 50;
binEdges = linspace(0, 1, nBins);

smooth = false;
histReal = histoutline(neuronPVal, binEdges, smooth, 'Normalization', 'probability');
histShuffle = histoutline(shufflePVal, binEdges, smooth, 'Normalization', 'probability');
uistack(histReal,'top');
histReal.LineWidth = 2;
histShuffle.LineWidth = 2;
beautifyPlot(figH, axH);

%label
axH.XLabel.String = 'P value';
axH.YLabel.String = 'Fraction of neurons';

legend([histReal, histShuffle],{'Real','Shuffled'},...
    'Location','NorthEast');