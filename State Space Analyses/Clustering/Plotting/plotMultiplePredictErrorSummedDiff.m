function plotMultiplePredictErrorSummedDiff(folder,fileStr)
%plotMultipleClusteredBehavioralDistribution.m Plots multiple beahvioral
%distributions for clusters 
%
%INPUTS
%folder - folder to search in
%fileStr - file string to match 
%
%ASM 6/15

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%get nDset 
nDatasets = length(matchFiles);

%loop through each file and create array 
allOut = cell(nDatasets,1);
for fileInd = 1:nDatasets
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    allOut{fileInd} = currFileData.out;
end

%create figure 
figH = figure;
axH = axes; 
hold(axH,'on');

%get all summedDiff and shuffleDiff 
allSummedDiff = cellfun(@(x) x.realSummedDiff,allOut);
allConfInt = nan(nDatasets,2);
allMedians = nan(nDatasets,1);
for dSet = 1:nDatasets 
    tempConfInt = prctile(allOut{dSet}.shuffledSummedDiff,[0.5 99.5]);
    allMedians(dSet) = median(allOut{dSet}.shuffledSummedDiff);
    allConfInt(dSet,:) = abs(bsxfun(@minus,allMedians(dSet),tempConfInt));
end

%generate colors 
colors = distinguishable_colors(nDatasets);

%plot scatter
scatH = scatter(1:nDatasets,allSummedDiff,150,'b','filled');

%plot errorbars
for dSet = 1:nDatasets
    errH = errorbar(dSet,allMedians(dSet),allConfInt(dSet,1),allConfInt(dSet,2));
%     errH.Color = colors(dSet,:);
    errH.Color = 'b';
    errH.LineWidth = 3;
end

%beautify 
beautifyPlot(figH,axH);

%label 
axH.XTick = [];
axH.YLabel.String = 'Summed difference from uniform';
axH.XLabel.String = 'Dataset';
axH.XLim = [-nDatasets 2*nDatasets];