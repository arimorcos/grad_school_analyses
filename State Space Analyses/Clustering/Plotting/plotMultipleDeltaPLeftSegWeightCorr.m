function handles = plotMultipleDeltaPLeftSegWeightCorr(folder,fileStr)
%plotMultipleDeltaPLeftSegWeightCorr.m Plots multiple correlations between
%delta p(left) and segment weights
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
segWeights = cell(nFiles,1);
deltaPLeft = cell(nFiles,1);
deltaPLeftShuffle = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    segWeights{fileInd} = currFileData.segWeights;
    deltaPLeft{fileInd} = currFileData.deltaPLeft;
    deltaPLeftShuffle{fileInd} = currFileData.deltaPLeftShuffle;
end

% calculate correlations 
realCorrCoef = nan(nFiles,1);
shuffleCorrCoefMed = nan(nFiles,1);
shuffleCorrCoefBounds = nan(nFiles,2);
for fileInd = 1:nFiles
    
    %get real corr coef 
    temp = corrcoef(nanmean(abs(deltaPLeft{fileInd}(:,1:6))),segWeights{fileInd});
    realCorrCoef(fileInd) = temp(1,2);
    
    %get shuffled corr coef 
    shuffledMeans = squeeze(nanmean(abs(deltaPLeftShuffle{fileInd}(:,1:6,:))));
    temp = arrayfun(@(x) corrcoef(segWeights{fileInd},shuffledMeans(:,x)),1:size(shuffledMeans,2),'uniformoutput',false);
    shuffleCorr = cellfun(@(x) x(1,2),temp);
    shuffleCorrCoefMed(fileInd) = median(shuffleCorr);
    shuffleCorrCoefBounds(fileInd,:) = abs(shuffleCorrCoefMed(fileInd) - prctile(shuffleCorr,[2.5 97.5]));
end

%% plot 
figH = figure; 
axH = axes; 
hold(axH,'on');

xVals = linspace(-0.5, 0.5, nFiles);

% plot points 
scatReal = scatter(xVals,realCorrCoef);
scatReal.MarkerFaceColor = 'r';
scatReal.MarkerEdgeColor = 'r';

%plot shuffle 
scatShuffle = errorbar(xVals,shuffleCorrCoefMed, shuffleCorrCoefBounds(:,1),...
    shuffleCorrCoefBounds(:,2));
scatShuffle.Color = 'b';
scatShuffle.Marker = 'none';
scatShuffle.LineWidth = 2;
scatShuffle.LineStyle = 'none';

%beautify
beautifyPlot(figH, axH);

%label 
axH.XTick = [];
axH.XLim = [-1 1];
axH.XLabel.String = 'Dataset';
axH.YLabel.String = 'Correlation Coefficient';