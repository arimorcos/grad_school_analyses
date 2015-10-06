function plotMultipleOverlapCorrCoefVsDeltaPLeft(folder, fileStr)
%plotOverlapCorrCoefVsDeltaPLeft.m Plots the output of
%calcOverlapCorrCoefVsDeltaPLeft in two plots for all points together
%
%INPUTS
%out - output of calcOverlapCorrCoefVsDeltaPLeft
%
%OUTPUTS
%
%ASM 10/15

% noiseScale = 0.01;
shadedError = false;

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

%% plot overlap

figH = figure;
axOverlap = subplot(1,2,1);
hold(axOverlap,'on');


%define xVals
xVals = 0:0.01:1;
yhat = nan(nFiles, length(xVals));

for file = 1:nFiles
    
    %concatenate
    startEpoch = 1;
    endEpoch = 10;
    deltaPLeft = cat(1, out{file}.deltaPLeft{startEpoch:endEpoch});
    overlap = cat(1, out{file}.overlap{startEpoch:endEpoch});
    
    
    %fit model
    lm = fitlm(deltaPLeft, overlap);
    
    %get yhat
    yhat(file,:) = predict(lm, xVals');
    
    %plot
    if ~shadedError
        plotOverlap = plot(xVals, yhat);
        plotOverlap.LineWidth = 2;
    end
end

if shadedError
    colors = lines(1);
    overlapPlot = shadedErrorBar(xVals, mean(yhat), calcSEM(yhat));
    overlapPlot.mainLine.Color = colors(1,:);
    overlapPlot.patch.FaceColor = colors(1,:);
    overlapPlot.patch.FaceAlpha = 0.3;
    overlapPlot.edge(1).Color = colors(1,:);
    overlapPlot.edge(2).Color = colors(1,:);
end

beautifyPlot(figH, axOverlap);

%label
axOverlap.XLabel.String = '\Delta p(Left)';
axOverlap.YLabel.String = 'Overlap index';
axOverlap.YLim = [0, 1];

%% correlation
axCorr = subplot(1,2,2);
hold(axCorr,'on');
yhat = nan(nFiles, length(xVals));

for file = 1:nFiles
    
    %concatenate
    startEpoch = 1;
    endEpoch = 10;
    deltaPLeft = cat(1, out{file}.deltaPLeft{startEpoch:endEpoch});
    corr = cat(1, out{file}.corr{startEpoch:endEpoch});
    
    %fit model
    lm = fitlm(deltaPLeft, corr);
    
    %get yhat
    yhat(file,:) = predict(lm, xVals');
    
    %plot
    if ~shadedError
        plotCorr = plot(xVals, yhat);
        plotCorr.LineWidth = 2;
    end
end

if shadedError
    colors = lines(1);
    corrPlot = shadedErrorBar(xVals, mean(yhat), calcSEM(yhat));
    corrPlot.mainLine.Color = colors(1,:);
    corrPlot.patch.FaceColor = colors(1,:);
    corrPlot.patch.FaceAlpha = 0.3;
    corrPlot.edge(1).Color = colors(1,:);
    corrPlot.edge(2).Color = colors(1,:);
end

beautifyPlot(figH, axCorr);

%label
axCorr.XLabel.String = '\Delta p(Left)';
axCorr.YLabel.String = 'Correlation coefficient';
axCorr.YLim = [0, 1];
