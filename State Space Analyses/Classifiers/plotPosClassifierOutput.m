function figH = plotPosClassifierOutput(classOut)
%plotPosClassifierOutput.m Plots the output of the position classifier
%
%INPUTS
%classOut - classifier output by classifyNetEvIndSegSVM
%
%OUTPUTS
%figH - figure handle
%
%ASM 4/15

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

%% Guess vs actual
axGuessVsActual = subplot(2,2,3);
hold(axGuessVsActual,'on');

scatH = scatter(classOut.guess,classOut.testClass);
scatH.MarkerEdgeColor = 'b';
scatH.MarkerFaceColor = 'b';
scatH.Marker = 'o';

%plot unity line
minVal = min(cat(1,classOut.testClass,classOut.guess));
maxVal = max(cat(1,classOut.testClass,classOut.guess));
plot([minVal maxVal], [minVal maxVal],'k--');
axis square;

axGuessVsActual.Title.String = 'Guess vs. actual position';
axGuessVsActual.XLabel.String = 'Actual Position';
axGuessVsActual.YLim = [minVal maxVal];
axGuessVsActual.XLim = [minVal maxVal];
axGuessVsActual.YLabel.String = 'Guessed position';


%% Fit MSE

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

maxfig(figH,1);
