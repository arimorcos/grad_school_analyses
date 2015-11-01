function plotMultipleAcrossEpochCorrVsTransProb(folder,fileStr)
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
    overlapDelta = nan(nDelta,1);
    meanCorrDelta = nan(nDelta,1);
    maxCorrDelta = nan(nDelta,1);
    transProbLM = cell(nDelta,1);
    for delta = 1:nDelta
        keepInd = deltaEpochVec == whichDelta(delta);
        overlapDelta(delta) = nanmean(overlapVec(keepInd));
        meanCorrDelta(delta) = nanmean(clusterCorrVec(keepInd));
        maxCorrDelta(delta) = max(clusterCorrVec(keepInd));
        
        if delta > 1
            transProbLM{delta} = fitlm(transMatVec(keepInd), clusterCorrVec(keepInd));
            tempCorr = corrcoef(transMatVec(keepInd), clusterCorrVec(keepInd));
            corrCoef(file,delta-1) = tempCorr(1,2);
        end
        
        if delta==5
            %group
            allClusterCorrVec = cat(1,allClusterCorrVec, clusterCorrVec(keepInd));
            allTransMatVec = cat(1,allTransMatVec, transMatVec(keepInd));
        end
    end
    
    % calculate slope and get predictions
    
    predictions(file,:) = predict(transProbLM{2}, xVals');
    for delta = 2:nDelta
        slope(file,delta-1) = transProbLM{delta}.Coefficients.Estimate(2);
    end
    
    
    
end

%% get correlation and p value
[corr,pVal] = corrcoef(allTransMatVec,allClusterCorrVec);


%% create figure and plot
figH = figure;

%% plot corr vs. trans probability

axLeft = subplot(1, 2, 1);

%calculate mean and sem
meanVal = mean(predictions);
semVal = calcSEM(predictions);

errH = shadedErrorBar(xVals,meanVal,semVal);
color = [0    0.4470    0.7410];
errH.mainLine.Color = color;
errH.patch.FaceColor = color;
errH.patch.FaceAlpha = 0.3;
errH.edge(1).Color = color;
errH.edge(2).Color = color;

beautifyPlot(figH, axLeft);
axLeft.XLabel.String = 'Transition probability';
axLeft.YLabel.String = 'Correlation coefficient';
axLeft.YLim = [0 1];
axLeft.XLim = [0 1];

%% plot distribution of slopes vs. delta epochs

axRight = subplot(1, 2, 2);

%calculate mean and sem
meanVal = mean(slope);
semVal = calcSEM(slope);
meanVal = mean(corrCoef);
semVal = calcSEM(corrCoef);

errH = shadedErrorBar(whichDelta(2:end),meanVal,semVal);
color = [0    0.4470    0.7410];
errH.mainLine.Color = color;
errH.patch.FaceColor = color;
errH.patch.FaceAlpha = 0.3;
errH.edge(1).Color = color;
errH.edge(2).Color = color;

beautifyPlot(figH, axRight);
axRight.XLabel.String = '\Delta epochs';
axRight.YLabel.String = 'Corr. coef. vs. trans. prob. slope';
