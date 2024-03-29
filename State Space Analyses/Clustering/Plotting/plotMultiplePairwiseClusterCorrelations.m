function handles = plotMultiplePairwiseClusterCorrelations(folder,fileStr, whichPoint)
%plotMultipleClusterVarFromFolder.m Plots multiple delta seg offset
%significance from folder
%
%INPUTS
%folder - path to folder
%fileStr - string to match files to
%
%OUTPUTS
%handles - structure of handles
%
%ASM 4/15

outline = true;
split_intra_inter = false;

%get list of files in folder
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array
all_left_intra = cell(length(matchFiles), 1);
all_left_inter = cell(length(matchFiles), 1);
all_right_intra = cell(length(matchFiles), 1);
all_right_inter = cell(length(matchFiles), 1);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    all_left_intra{fileInd} = cat(1, currFileData.left_intra{whichPoint});
    all_left_inter{fileInd} = cat(1, currFileData.left_inter{whichPoint});
    all_right_intra{fileInd} = cat(1, currFileData.right_intra{whichPoint});
    all_right_inter{fileInd} = cat(1, currFileData.right_inter{whichPoint});
end

%% plot
figH = figure;
axH = axes;
hold(axH, 'on');

all_intra = cat(1, all_left_intra{:}, all_right_intra{:});
all_inter = cat(1, all_left_inter{:}, all_right_inter{:});

minVal = min(cat(1,all_intra,all_inter));
maxVal = max(cat(1,all_intra,all_inter));
nBins = 50;
binEdges = linspace(minVal,maxVal,nBins+1);

%histograms
if ~split_intra_inter
    if outline
        allH = histoutline(cat(1, all_intra, all_inter), binEdges, false,...
            'Normalization', 'Probability');
        intraH = histoutline(all_intra, binEdges, false,...
            'Normalization', 'Probability');
    else
        allH = histogram(cat(1, all_intra, all_inter), binEdges, false,...
            'Normalization', 'Probability');
        intraH = histogram(all_intra, binEdges, false,...
            'Normalization', 'Probability');
    end
else
    if outline
        intraH = histoutline(all_intra, binEdges, false, 'Normalization', 'Probability');
        interH = histoutline(all_inter, binEdges, false, 'Normalization', 'Probability');
    else
        intraH = histogram(all_intra, binEdges, 'Normalization', 'Probability');
        interH = histogram(all_inter, binEdges, 'Normalization', 'Probability');
    end
end

%beautify
beautifyPlot(figH, axH);

axH.XLim = [minVal, maxVal];

%label
axH.XLabel.String = 'Trial-trial population correlation';
axH.YLabel.String = 'Fraction of trial pairs';

%legend
if split_intra_inter
    legH = legend([intraH, interH], {'Intra-cluster','Inter-cluster'},...
        'Location', 'Best');
else
    legH = legend([allH, intraH], {'All 6-0 trials','Intra-cluster'},...
        'Location', 'Best');
end





