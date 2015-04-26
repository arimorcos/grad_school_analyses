function figH = plotPosClassifierOutput(classOut,plotAll)
%plotPosClassifierOutput.m Plots the output of the position classifier
%
%INPUTS
%classOut - classifier output by classifyNetEvIndSegSVM
%
%OUTPUTS
%figH - figure handle
%
%ASM 4/15

if nargin < 2 || isempty(plotAll)
    plotAll = true;
end

confInt = 95;

%initialize
shuffleMSE = nan(1,3);
shuffleCorrCoef = nan(1,3);

%determine confidence interval range
lowConf = (100 - confInt)/2;
highConf = 100 - lowConf;

%store data
mse = classOut.mse;
corrCoef = classOut.corrCoef;

%get confidence intervals
shuffleMSE(1) = median(classOut.shuffleMSE);
shuffleMSE(2:3) = prctile(classOut.shuffleMSE,[lowConf,highConf]);
shuffleMSE(2:3) = abs(bsxfun(@minus,shuffleMSE(2:3),shuffleMSE(1)));

shuffleCorrCoef(1) = median(classOut.shuffleCorrCoef);
shuffleCorrCoef(2:3) = prctile(classOut.shuffleCorrCoef,[lowConf,highConf]);
shuffleCorrCoef(2:3) = abs(bsxfun(@minus,shuffleCorrCoef(2:3),...
    shuffleCorrCoef(1)));


%plot
figH = figure;

%% Model MSE
if plotAll
    axMSE = subplot(2,2,1);
    hold(axMSE,'on');
    colors = distinguishable_colors(1);
    
    %plot actual data for mse
    scatH = scatter(1,mse);
    scatH.MarkerEdgeColor = colors(1,:);
    scatH.MarkerFaceColor = colors(1,:);
    
    %plot shuffle
    errH = errorbar(1,shuffleMSE(1),...
        shuffleMSE(2),shuffleMSE(3));
    errH.Color = colors(1,:);
    errH.LineWidth = 2;
    errH.LineStyle = 'none';
    
    %set limit
    axMSE.XLim = [0.5 1.5];
    axMSE.XTick = [];
    
    %set labels
    axMSE.YLabel.String = 'Mean Squared Error';
    axMSE.Title.String = 'Model MSE';
    
    %% CorrCoef
    axCorrCoef = subplot(2,2,2);
    hold(axCorrCoef,'on');
    colors = distinguishable_colors(1);
    
    %plot actual data for mse
    scatH = scatter(1,corrCoef);
    scatH.MarkerEdgeColor = colors(1,:);
    scatH.MarkerFaceColor = colors(1,:);
    
    %plot shuffle
    errH = errorbar(1,shuffleCorrCoef(1),...
        shuffleCorrCoef(2),shuffleCorrCoef(3));
    errH.Color = colors(1,:);
    errH.LineWidth = 2;
    errH.LineStyle = 'none';
    
    %set limit
    axCorrCoef.XLim = [0.5 1.5];
    axCorrCoef.XTick = [];
    
    %set labels
    axCorrCoef.YLabel.String = 'Squared Correlation Coefficient';
    axCorrCoef.Title.String = 'R^2';
    
end
%% Guess vs actual
if plotAll
    axGuessVsActual = subplot(2,2,3);
    axGuessVsActual.Title.String = 'Guess vs. actual position';
else
    axGuessVsActual = axes;
    axGuessVsActual.FontSize = 20;
    axGuessVsActual.XLabel.FontSize = 30;
    axGuessVsActual.YLabel.FontSize = 30;
end
hold(axGuessVsActual,'on');

%convert to cm
cmScale = 0.75;
classOut.guess = classOut.guess*cmScale;
classOut.testClass = classOut.testClass*cmScale;

scatH = scatter(classOut.guess,classOut.testClass);
% scatH.MarkerEdgeColor = 'b';
% scatH.MarkerFaceColor = 'b';
scatH.Marker = 'o';

%plot unity line
minVal = min(cat(1,classOut.testClass,classOut.guess));
maxVal = max(cat(1,classOut.testClass,classOut.guess));
plot([minVal maxVal], [minVal maxVal],'k--');
axis square;

%get binned means
nBins = 100;
binVals = linspace(minVal,maxVal,nBins+1);
meanVals = nan(nBins,1);
semVals = nan(nBins,1);
xVals = binVals(1:nBins) + mean(diff(binVals))/2;
for binInd = 1:nBins
    keepInd = classOut.testClass > binVals(binInd) & classOut.testClass <= binVals(binInd+1);
    meanVals(binInd) = mean(classOut.guess(keepInd));
    semVals(binInd) = calcSEM(classOut.guess(keepInd));
end

%add to plot
errMean = errorbar(xVals,meanVals,semVals);
errMean.Marker = 'o';
errMean.MarkerEdgeColor = 'r';
errMean.MarkerFaceColor = 'r';
errMean.LineStyle = 'none';
errMean.Color = 'r';
errMean.LineWidth = 2;

axGuessVsActual.XLabel.String = 'Actual Position (cm)';
axGuessVsActual.YLim = [minVal maxVal];
axGuessVsActual.XLim = [minVal maxVal];
axGuessVsActual.YLabel.String = 'Guessed Position (cm)';


%% Fit MSE
if plotAll
    axGuessVsActualMSE = subplot(2,2,4);
    hold(axGuessVsActualMSE,'on');
    colors = distinguishable_colors(1);
    
    %plot actual data for mse
    %get absolute difference
    absDiff = abs(classOut.guess - classOut.testClass);
    
    %take mean of squares
    mse = mean(absDiff.^2);
    
    scatH = scatter(1,mse);
    scatH.MarkerEdgeColor = colors(1,:);
    scatH.MarkerFaceColor = colors(1,:);
    
    %plot shuffle
    
    %get absolute difference
    guessDiff = classOut.shuffleGuess - classOut.shuffleTestClass;
    
    %take mean of squares
    mse = squeeze(mean(guessDiff.^2))';
    shuffleMed = median(mse);
    confInt = prctile(mse,[lowConf, highConf]);
    confInt = abs(confInt - shuffleMed);
    
    errH = errorbar(1,shuffleMed,...
        confInt(1),confInt(2));
    errH.Color = colors(1,:);
    errH.LineWidth = 2;
    errH.LineStyle = 'none';
    
    %set limit
    axGuessVsActualMSE.XLim = [0.5 1.5];
    axGuessVsActualMSE.XTick = [];
    
    %set labels
    axGuessVsActualMSE.YLabel.String = 'Mean Squared Error';
    axGuessVsActualMSE.Title.String = 'Guess vs. actual MSE';
    
end
maxfig(figH,1);
