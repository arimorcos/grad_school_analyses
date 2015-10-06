function plotMultipleClusteredHistAccuracy(folder,fileStr)
%plotMultipleClusteredHistAccuracy.m Plots the output of
%predictHistoryFromClusters for multiple mice
%
%ASM 7/15

accMode = true;
useSlope = false;

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
axH = subplot(2,2,1);
% axH = axes;
hold(axH, 'on');

%loop through each file and plot
nFiles = length(matchFiles);
xVals = linspace(0.75,1.25, nFiles);
for file = 1:nFiles
    
    %plot accuracy
    scatH = scatter(xVals(file),100*allAcc(file),'b','filled');
    
    %plot shuffle
    medShuffle = median(100*allShuffleAcc{file});
    confInt = prctile(100*allShuffleAcc{file},[2.5 97.5]);
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
axH.XLim = [0.5 1.5];


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

if accMode
    if strcmpi(computer,'MACI64')
        load('/Users/arimorcos/Data/Analyzed Data/150910_vogel_firstSegAcc/firstSeg_maxAcc.mat');
    else
        load('D:\DATA\Analyzed Data\150910_vogel_firstSegAcc\firstSeg_maxAcc.mat');
    end
    singleSegAcc = maxAcc;
else
    if strcmpi(computer,'MACI64')
        load('/Users/arimorcos/Data/Analyzed Data/150728_clusteredHistAcc/singleSegNSTD.mat');
    else
        load('D:\DATA\Analyzed Data\150728_clusteredHistAcc\singleSegNSTD.mat');
    end
end
axB = subplot(2,2,2);
hold(axB,'on');

if accMode
    scatH=scatter(100*allAcc,singleSegAcc);
    scatH.MarkerEdgeColor = [0.7 0.7 0.7];
    scatH.MarkerFaceColor = [0.7 0.7 0.7];
    scatH.SizeData = 150;
    
    beautifyPlot(figH,axB);
    corr = corrcoef(allAcc,singleSegAcc);
    shuffleCorr = nan(1000,1);
    for i = 1:1000
        temp = corrcoef(allAcc,shuffleArray(singleSegAcc));
        shuffleCorr(i) = temp(1,2);
    end
    shuffleCorr = sort(shuffleCorr);
    pVal = 1 - find(corr(1,2) >= shuffleCorr,1,'last')/1000;
    % legend('Segment nSTD','History nSTD','Location','Best');
    axB.YLabel.String = 'Current cue accuracy';
    % axB.XTick = [];
    axB.XLabel.String = 'Previous cue accuracy';
    textH = text(axB.XLim(1) + 0.02*range(axB.XLim),axB.YLim(2)-0.02*range(axB.YLim),...
        sprintf('r = %.3f',corr(1,2)));
    textH.HorizontalAlignment = 'Left';
    textH.VerticalAlignment = 'Top';
    fprintf('History, first cue corr: r = %.3f, p = %.3f\n',corr(1,2),pVal);
    
else
    scatH=scatter(allNSTD,nSTD);
    scatH.MarkerEdgeColor = [0.7 0.7 0.7];
    scatH.MarkerFaceColor = [0.7 0.7 0.7];
    scatH.SizeData = 150;
    
    beautifyPlot(figH,axB);
    [corr,pVal] = corrcoef(nSTD,allNSTD);
    % legend('Segment nSTD','History nSTD','Location','Best');
    axB.YLabel.String = 'First Segment Accuracy (std)';
    % axB.XTick = [];
    axB.XLabel.String = 'History Accuracy (std)';
    textH = text(axB.XLim(1) + 0.02*range(axB.XLim),axB.YLim(2)-0.02*range(axB.YLim),...
        sprintf('r = %.3f',corr(1,2)));
    textH.HorizontalAlignment = 'Left';
    textH.VerticalAlignment = 'Top';
    fprintf('History, first cue corr: r = %.3f, p = %.3f\n',corr(1,2),pVal(1,2));
end

%% plot slope
if useSlope 
    if strcmpi(computer, 'MACI64')
        load('/Users/arimorcos/Data/Analyzed Data/150824_oldDeconv_smooth10_SVM/netEvSVR_slope.mat');
    else
        load('D:\DATA\Analyzed Data\150824_oldDeconv_smooth10_SVM\netEvSVR_slope.mat');
    end
    slope = slopeNetEv;
else
    if strcmpi(computer, 'MACI64')
        load('/Users/arimorcos/Data/Analyzed Data/150824_oldDeconv_smooth10_SVM/netEVSVR_corrCoef.mat');
    else
        load('D:\DATA\Analyzed Data\150824_oldDeconv_smooth10_SVM\netEVSVR_corrCoef.mat');
    end
    slope = corrCoefNetEv;
end
axB = subplot(2,2,3);
hold(axB,'on');

if accMode
    scatH = scatter(singleSegAcc,slope);
    scatH.MarkerEdgeColor = [0.7 0.7 0.7];
    scatH.MarkerFaceColor = [0.7 0.7 0.7];
    scatH.SizeData = 150;
    
    beautifyPlot(figH,axB);
    corr = corrcoef(singleSegAcc,slope);
    shuffleCorr = nan(1000,1);
    for i = 1:1000
        temp = corrcoef(slope,shuffleArray(singleSegAcc));
        shuffleCorr(i) = temp(1,2);
    end
    shuffleCorr = sort(shuffleCorr);
    pVal = 1 - find(corr(1,2) >= shuffleCorr,1,'last')/1000;
    axB.YLabel.String = 'Net evidence slope';
    axB.XLabel.String = 'Current cue accuracy';
    textH = text(axB.XLim(1) + 0.02*range(axB.XLim),axB.YLim(2)-0.02*range(axB.YLim),...
        sprintf('r = %.3f',corr(1,2)));
    textH.HorizontalAlignment = 'Left';
    textH.VerticalAlignment = 'Top';
    fprintf('NetEv, first cue corr: r = %.3f, p = %.3f\n',corr(1,2),pVal);
else
    scatH = scatter(nSTD,slope);
    scatH.MarkerEdgeColor = [0.7 0.7 0.7];
    scatH.MarkerFaceColor = [0.7 0.7 0.7];
    scatH.SizeData = 150;
    
    beautifyPlot(figH,axB);
    [corr,pVal] = corrcoef(nSTD,slope);
    axB.YLabel.String = 'Net Evidence Slope';
    axB.XLabel.String = 'First Segment Accuracy (std)';
    textH = text(axB.XLim(1) + 0.02*range(axB.XLim),axB.YLim(2)-0.02*range(axB.YLim),...
        sprintf('r = %.3f',corr(1,2)));
    textH.HorizontalAlignment = 'Left';
    textH.VerticalAlignment = 'Top';
    fprintf('NetEv, first cue corr: r = %.3f, p = %.3f\n',corr(1,2),pVal(1,2));
end

%% plot slope
if strcmpi(computer, 'MACI64') 
    load('/Users/arimorcos/Data/Analyzed Data/150728_clusteredHistAcc/netEvSlope.mat');
else
    load('D:\DATA\Analyzed Data\150728_clusteredHistAcc\netEvSlope.mat');
end
axB = subplot(2,2,4);
hold(axB,'on');

if accMode
    scatH = scatter(100*allAcc,slope);
    scatH.MarkerEdgeColor = [0.7 0.7 0.7];
    scatH.MarkerFaceColor = [0.7 0.7 0.7];
    scatH.SizeData = 150;
    beautifyPlot(figH,axB);
    corr = corrcoef(100*allAcc,slope);
    shuffleCorr = nan(1000,1);
    for i = 1:1000
        temp = corrcoef(allAcc,shuffleArray(slope));
        shuffleCorr(i) = temp(1,2);
    end
    shuffleCorr = sort(shuffleCorr);
    pVal = 1 - find(corr(1,2) >= shuffleCorr,1,'last')/1000;
    axB.YLabel.String = 'Net evidence slope';
    axB.XLabel.String = 'Previous cue accuracy';
    textH = text(axB.XLim(1) + 0.02*range(axB.XLim),axB.YLim(2)-0.02*range(axB.YLim),...
        sprintf('r = %.3f',corr(1,2)));
    textH.HorizontalAlignment = 'Left';
    textH.VerticalAlignment = 'Top';
    fprintf('History, NetEv corr: r = %.3f, p = %.3f\n',corr(1,2),pVal);
else
    scatH = scatter(allNSTD,slope);
    scatH.MarkerEdgeColor = [0.7 0.7 0.7];
    scatH.MarkerFaceColor = [0.7 0.7 0.7];
    scatH.SizeData = 150;
    beautifyPlot(figH,axB);
    [corr,pVal] = corrcoef(allNSTD,slope);
    axB.YLabel.String = 'Net Evidence Slope';
    axB.XLabel.String = 'History Accuracy (std)';
    textH = text(axB.XLim(1) + 0.02*range(axB.XLim),axB.YLim(2)-0.02*range(axB.YLim),...
        sprintf('r = %.3f',corr(1,2)));
    textH.HorizontalAlignment = 'Left';
    textH.VerticalAlignment = 'Top';
    fprintf('History, NetEv corr: r = %.3f, p = %.3f\n',corr(1,2),pVal(1,2));
end
