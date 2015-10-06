function plotMultipleConditionalPairwiseCorrelations(folder,fileStr)
%plotMultipleConditionalPairwiseCorrelations.m Plots multiple conditional
%pairwise correlations
%
%INPUTS
%folder - path to folder
%fileStr - string to match files to
%
%OUTPUTS
%handles - structure of handles
%
%ASM 10/15

plotDiff = true;
showSig = false;

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

%% align and combine
nBinsAll = cellfun(@(x) size(x.allCorr,2),out);
minBins = min(nBinsAll);

allCorr = nan(nFiles, minBins);
turnCorr = nan(size(allCorr));
turn60Corr = nan(size(allCorr));
diffTurnCorr = nan(size(allCorr));
yPosBins = nan(size(allCorr));
%loop through and combine
for file = 1:nFiles
    
    allCorr(file,:) = mean(out{file}.allCorr(:,1:minBins));
    turnCorr(file,:) = mean(out{file}.turnCorr(:,1:minBins));
    turn60Corr(file,:) = mean(out{file}.turn60Corr(:,1:minBins));
    diffTurnCorr(file,:) = mean(out{file}.diffTurnCorr(:,1:minBins));
    yPosBins(file,:) = out{file}.yPosBins(:,1:minBins);
    
end


%% calculate significance
if showSig
    allTurnPVal = nan(1, minBins);
    allTurn60PVal = nan(size(allTurnPVal));
    turnTurn60PVal = nan(size(allTurnPVal));
    
    % loop through each bin
    for bin = 1:minBins
        
        [~, allTurnPVal(bin)] = ttest2(allCorr(:,bin), turnCorr(:,bin));
        [~, allTurn60PVal(bin)] = ttest2(allCorr(:,bin), turn60Corr(:,bin));
        [~, turnTurn60PVal(bin)] = ttest2(turnCorr(:,bin), turn60Corr(:,bin));
        
    end
    allTurnSig = allTurnPVal < 0.05;
    
    allTurn60Sig = allTurn60PVal < 0.05;
    
    turnTurn60Sig = turnTurn60PVal < 0.05;
end
%% plot

%create figure
figH = figure;
axH = axes;
cmScale = 0.75;

%turn on hold
hold(axH, 'on');

%get colors
colors = lines(4);

%plot all
xVals = cmScale*mean(yPosBins);
meanAll = mean(allCorr);
semAll = calcSEM(allCorr);
allPlot = shadedErrorBar(xVals, meanAll, semAll);
allPlot.mainLine.Color = colors(1,:);
allPlot.patch.FaceColor = colors(1,:);
allPlot.patch.FaceAlpha = 0.3;
allPlot.edge(1).Color = colors(1,:);
allPlot.edge(2).Color = colors(1,:);

%plot turn
meanTurn = mean(turnCorr);
semTurn = calcSEM(turnCorr);
turnPlot = shadedErrorBar(xVals, meanTurn, semTurn);
turnPlot.mainLine.Color = colors(2,:);
turnPlot.patch.FaceColor = colors(2,:);
turnPlot.patch.FaceAlpha = 0.3;
turnPlot.edge(1).Color = colors(2,:);
turnPlot.edge(2).Color = colors(2,:);

%plot 6-0 turn
meanTurn60 = mean(turn60Corr);
semTurn60 = calcSEM(turn60Corr);
turn60Plot = shadedErrorBar(xVals, meanTurn60, semTurn60);
turn60Plot.mainLine.Color = colors(3,:);
turn60Plot.patch.FaceColor = colors(3,:);
turn60Plot.patch.FaceAlpha = 0.3;
turn60Plot.edge(1).Color = colors(3,:);
turn60Plot.edge(2).Color = colors(3,:);

if plotDiff
    %plot diff turn
    meanDiffTurn = mean(diffTurnCorr);
    semDiffTurn = calcSEM(diffTurnCorr);
    diffTurnPlot = shadedErrorBar(xVals, meanDiffTurn, semDiffTurn);
    diffTurnPlot.mainLine.Color = colors(4,:);
    diffTurnPlot.patch.FaceColor = colors(4,:);
    diffTurnPlot.patch.FaceAlpha = 0.3;
    diffTurnPlot.edge(1).Color = colors(4,:);
    diffTurnPlot.edge(2).Color = colors(4,:);
end
if showSig
    %add significance lines
    currYMax = axH.YLim(2);
    axH.YLim(2) = 1.05*currYMax;
    
    allTurnY = repmat(currYMax-0.02,minBins,1);
    allTurnY(~allTurnSig) = NaN;
    allTurnSigLine = plot(xVals, allTurnY);
    allTurnSigLine.Color = colors(4,:);
    allTurnSigLine.LineWidth = 2;
    
    allTurn60Y = repmat(currYMax,minBins,1);
    allTurn60Y(~allTurn60Sig) = NaN;
    allTurn60SigLine = plot(xVals, allTurn60Y);
    allTurn60SigLine.Color = colors(5,:);
    allTurn60SigLine.LineWidth = 2;
    
    turnTurn60Y = repmat(currYMax + 0.02,minBins,1);
    turnTurn60Y(~turnTurn60Sig) = NaN;
    turnTurn60SigLine = plot(xVals, turnTurn60Y);
    turnTurn60SigLine.Color = colors(6,:);
    turnTurn60SigLine.LineWidth = 2;
end

%beautify
beautifyPlot(figH, axH);

%ylim
axH.XLim = [min(xVals) max(xVals)];

%label
axH.XLabel.String = 'Maze position (cm)';
axH.YLabel.String = 'Pairwise trial-trial correlation coefficient';

%legend
if showSig
    legH = legend([allPlot.mainLine, turnPlot.mainLine, turn60Plot.mainLine,...
        allTurnSigLine, allTurn60SigLine, turnTurn60SigLine],...
        {'All trials','Same turn trials','Same turn 6-0 trials',...
        'All-turn sig.', 'All-turn60 sig.', 'Turn-turn60 sig.'},'Location',...
        'BestOutside');
elseif plotDiff
    legH = legend([allPlot.mainLine, turnPlot.mainLine, turn60Plot.mainLine,...
        diffTurnPlot.mainLine],...
        {'All trials','Same turn trials','Same turn 6-0 trials','Diff turn trials'},...
        'Location','BestOutside');
else
    legH = legend([allPlot.mainLine, turnPlot.mainLine, turn60Plot.mainLine],...
        {'All trials','Same turn trials','Same turn 6-0 trials'},'Location',...
        'BestOutside');
end
