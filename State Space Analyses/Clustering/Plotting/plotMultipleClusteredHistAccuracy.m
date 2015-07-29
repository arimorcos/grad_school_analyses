function plotMultipleClusteredHistAccuracy(folder,fileStr)
%plotMultipleClusteredHistAccuracy.m Plots the output of
%predictHistoryFromClusters for multiple mice
%
%ASM 7/15

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array 
allAcc = nan(length(matchFiles),1);
allShuffleAcc = cell(size(allAcc));
allNSTD = nan(size(allAcc));
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    allAcc(fileInd) = currFileData.accuracy;
    allShuffleAcc{fileInd} = currFileData.shuffleAccuracy;
    allNSTD(fileInd) = currFileData.nSTD;
end


%% plot 
figH = figure;
axH = subplot(2,1,1);
% axH = axes;
hold(axH, 'on');

%loop through each file and plot 
nFiles = length(matchFiles);
xVals = linspace(0.75,1.25, nFiles);
for file = 1:nFiles
    
    %plot accuracy 
    scatH = scatter(xVals(file),allAcc(file),'b','filled');
    
    %plot shuffle 
    medShuffle = median(allShuffleAcc{file});
    confInt = prctile(allShuffleAcc{file},[2.5 97.5]);
    confInt = abs(confInt - medShuffle);
    errH = errorbar(xVals(file),medShuffle,confInt(1),confInt(2));
    errH.Color = 'b';
    
end

%beuatify 
beautifyPlot(figH, axH);

%label
axH.XTick = [];
axH.XLabel.String = 'Dataset';
axH.YLabel.String = 'History Classification Accuracy';

%% plot nSTD 
% load('D:\DATA\Analyzed Data\150728_clusteredHistAcc\singleSegNSTD.mat');
% axB = subplot(2,1,2);
% hold(axB,'on');
% scatter(xVals,nSTD,'r','filled');
% scatter(xVals,allNSTD,'b','filled');
% beautifyPlot(figH,axB);
% corr = corrcoef(nSTD,allNSTD);
% legend('Segment nSTD','History nSTD','Location','Best');
% axB.XLabel.String = 'Dataset';
% axB.XTick = [];
% axB.YLabel.String = 'nSTD Above Chance';

load('D:\DATA\Analyzed Data\150728_clusteredHistAcc\singleSegNSTD.mat');
axB = subplot(2,2,3);
hold(axB,'on');
scatter(allNSTD,nSTD);
beautifyPlot(figH,axB);
corr = corrcoef(nSTD,allNSTD);
% legend('Segment nSTD','History nSTD','Location','Best');
axB.YLabel.String = 'First Segment Accuracy (std)';
% axB.XTick = [];
axB.XLabel.String = 'History Accuracy (std)';
textH = text(axB.XLim(1) + 0.02*range(axB.XLim),axB.YLim(2)-0.02*range(axB.YLim),...
    sprintf('r = %.2f',corr(1,2)));
textH.HorizontalAlignment = 'Left';
textH.VerticalAlignment = 'Top';

%% plot slope 
load('D:\DATA\Analyzed Data\150728_clusteredHistAcc\netEvSlope.mat');
axB = subplot(2,2,4);
hold(axB,'on');
scatter(allNSTD,slope);
beautifyPlot(figH,axB);
corr = corrcoef(nSTD,slope);
axB.YLabel.String = 'Net Evidence Slope';
axB.XLabel.String = 'History Accuracy (std)';
textH = text(axB.XLim(1) + 0.02*range(axB.XLim),axB.YLim(2)-0.02*range(axB.YLim),...
    sprintf('r = %.2f',corr(1,2)));
textH.HorizontalAlignment = 'Left';
textH.VerticalAlignment = 'Top';
