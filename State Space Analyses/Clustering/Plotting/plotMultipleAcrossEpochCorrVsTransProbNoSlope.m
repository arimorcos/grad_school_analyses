function plotMultipleAcrossEpochCorrVsTransProbNoSlope(folder,fileStr)
%plotMultipleAcrossEpochCorrVsTransProb.m Plots the across epoch
%correlation for clusters vs. the transition probability
%
%ASM 10/15

%get list of files in folder
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));
nFiles = length(matchFiles);

%loop through each file and create array
allOverlapIndex = cell(nFiles,1);
allDeltaEpochs = cell(nFiles,1);
allClusterCorr = cell(nFiles,1);
allTransMat = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    allDeltaEpochs{fileInd} = currFileData.deltaEpochs;
    allClusterCorr{fileInd} = currFileData.clusterCorr;
    allTransMat{fileInd} = currFileData.transMat;
    allOverlapIndex{fileInd} = currFileData.overlapIndex;
end

%% loop throug and process
xVals = 0:0.1:1;
predictions = nan(nFiles,length(xVals));
slope = nan(nFiles,9);
corrCoef = nan(nFiles,9);
allTransMatVec = [];
allClusterCorrVec = [];

num_bins = 10;
bin_edges = linspace(0, 1, num_bins + 1);
binned_corr_means = nan(nFiles, 9, num_bins);
binned_corr_sem = nan(nFiles, 9, num_bins);


for file = 1:nFiles
    
    overlapIndex = allOverlapIndex{file};
    transMat = allTransMat{file};
    deltaEpochs = allDeltaEpochs{file};
    clusterCorr = allClusterCorr{file};
    
    % convert everything to triangular matrix
    nTotal = length(overlapIndex);
    nanInd = ~logical(triu(ones(nTotal),1));
    overlapIndex(nanInd) = NaN;
    clusterCorr(nanInd) = NaN;
    deltaEpochs(nanInd) = NaN;
    
    % convert to vectors
    overlapVec = overlapIndex(:);
    clusterCorrVec = clusterCorr(:);
    deltaEpochVec = deltaEpochs(:);
    transMatVec = transMat(:);
    
    % filter
    removeInd = nanInd(:);
    overlapVec(removeInd) = [];
    clusterCorrVec(removeInd) = [];
    deltaEpochVec(removeInd) = [];
    transMatVec(removeInd) = [];
    
    whichDelta = unique(deltaEpochVec);
    nDelta = length(whichDelta);
    
    % loop through and get mean for each

    for delta = 2:nDelta
        keepInd = deltaEpochVec == whichDelta(delta);
        
        for bin = 1:num_bins
            bin_vec = transMatVec >= bin_edges(bin) & transMatVec <= bin_edges(bin+1);
            use_vec = keepInd & bin_vec;
            binned_corr_means(file, delta-1, bin) = nanmean(clusterCorrVec(use_vec));
            binned_corr_sem(file, delta-1, bin) = calcSEM(clusterCorrVec(use_vec));
        end
    end
     
    
end

%% get correlation and p value
% [corr,pVal] = corrcoef(allTransMatVec,allClusterCorrVec)


%% create figure and plot
figH = figure;

%% plot corr vs. trans probability

which_delta = 2;
binned_corr_means = squeeze(nanmean(binned_corr_means(:, which_delta, :), 2));

axH = axes;

%calculate mean and sem
% meanVal = nanmean(squeeze(binned_corr_means(:, which_delta, :)));
% semVal = calcSEM(squeeze(binned_corr_means(:, which_delta, :)));
meanVal = nanmean(binned_corr_means);
semVal = calcSEM(binned_corr_means);
meanVal = cat(2, meanVal(1), meanVal);
semVal = cat(2, semVal(1), semVal);
% xVals = bin_edges(1:end-1) + mean(diff(bin_edges));
xVals = bin_edges;

errH = shadedErrorBar(xVals,meanVal,semVal);
color = [0    0.4470    0.7410];
errH.mainLine.Color = color;
errH.patch.FaceColor = color;
errH.patch.FaceAlpha = 0.3;
errH.edge(1).Color = color;
errH.edge(2).Color = color;

beautifyPlot(figH, axH);
axH.XLabel.String = 'Transition probability';
axH.YLabel.String = 'Correlation coefficient';
axH.YLim = [0 1];
axH.XLim = [0 1];

