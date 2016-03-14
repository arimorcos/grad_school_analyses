function handles = plotMultipleSingleClusterVarFromFolder(folder,fileStr)
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
nEpoch = 10;
pointLabels = {'Trial Start','Cue 1','Cue 2','Cue 3','Cue 4',...
    'Cue 5','Cue 6','Early Delay','Late Delay','Turn'};

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array 
allOut = cell(length(matchFiles),1);
meanFrac = nan(length(matchFiles),nEpoch);
shuffleMeanFrac = nan(1000, nEpoch, length(matchFiles));
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    allOut{fileInd} = currFileData.out;
    meanFrac(fileInd, :) = currFileData.out.meanFrac;
    shuffleMeanFrac(:, :, fileInd) = currFileData.out.shuffleMeanFrac(1:1000, :);
end


% get nSTD
nSTD = nan(size(meanFrac));
for fileInd = 1:length(matchFiles)
    median_shuffle = median(shuffleMeanFrac(:, :, fileInd));
    std_shuffle = std(shuffleMeanFrac(:, :, fileInd));
    
    nSTD(fileInd, :) = (median_shuffle - meanFrac(fileInd, :))./std_shuffle;
    
end


figH = figure;
axH = axes;

%hold
hold(axH,'on');

%loop through and plot
xVals = 1:nEpoch;
errReal = errorbar(xVals,nanmean(nSTD),calcSEM(nSTD));

%customize 
errReal.Marker = 'o';
errReal.MarkerFaceColor = errReal.Color;

%label
axH.XTick = xVals;
axH.XTickLabel = pointLabels;
axH.XTickLabelRotation = -45;
axH.YLabel.String = 'Number std below shuffle';

%limits
% axH.YLim = [0 1];
axH.XLim = [0.5 nEpoch+0.5];

%beautify
beautifyPlot(figH,axH);




