function figH = plotClassifierOutGroupSegSVM(classOut)
%plotClassifierOutIndSegSVM.m Plots the output of the individual segment
%classifier
%
%INPUTS
%classOut - classifier output by classifyNetEvIndSegSVM
%
%OUTPUTS
%figH - figure handle
%
%ASM 3/15

confInt = 95;
nSeg = 6;

%initialize
mse = nan(1,3);
corrCoef = nan(1,3);
shuffleMSE = nan(3,3);
shuffleCorrCoef = nan(3,3);

%determine confidence interval range
lowConf = (100 - confInt)/2;
highConf = 100 - lowConf;

%loop through each condition
for condInd = 1:3
    
    %store data
    mse(condInd) = classOut(condInd).mse;
    corrCoef(condInd) = classOut(condInd).corrCoef;
    
    %get confidence intervals
    shuffleMSE(condInd,1) = median(classOut(condInd).shuffleMSE);
    shuffleMSE(condInd,2:3) = prctile(classOut(condInd).shuffleMSE,[lowConf,highConf]);
    shuffleMSE(condInd,2:3) = abs(bsxfun(@minus,shuffleMSE(condInd,2:3),shuffleMSE(condInd,1)));
    
    shuffleCorrCoef(condInd,1) = median(classOut(condInd).shuffleCorrCoef);
    shuffleCorrCoef(condInd,2:3) = prctile(classOut(condInd).shuffleCorrCoef,[lowConf,highConf]);
    shuffleCorrCoef(condInd,2:3) = abs(bsxfun(@minus,shuffleCorrCoef(condInd,2:3),...
        shuffleCorrCoef(condInd,1)));
end


%plot
figH = figure;

%% Model MSE
axMSE = subplot(2,2,1);
hold(axMSE,'on');
colors = distinguishable_colors(3);

%plot actual data for mse
scatH = gobjects(1,3);
for condInd = 1:3
    scatH(condInd) = scatter(condInd,mse(condInd));
    scatH(condInd).MarkerEdgeColor = colors(condInd,:);
    scatH(condInd).MarkerFaceColor = colors(condInd,:);
end

%plot shuffle
for condInd = 1:3
    errH = errorbar(condInd,shuffleMSE(condInd,1),...
        shuffleMSE(condInd,2),shuffleMSE(condInd,3));
    errH.Color = colors(condInd,:);
    errH.LineWidth = 2;
    errH.LineStyle = 'none';
end

%set labels
axMSE.XTick = 1:3;
axMSE.XTickLabel = {'All Trials','Left Net Evidence','Right Net Evidence'};
axMSE.YLabel.String = 'Mean Squared Error';
axMSE.Title.String = 'Model MSE';
axMSE.XLabel.String = 'Segment Number';

%% CorrCoef
axCorrCoef = subplot(2,2,2);
hold(axCorrCoef,'on');
colors = distinguishable_colors(3);

%plot actual data for mse
scatH = gobjects(1,3);
for condInd = 1:3
    scatH(condInd) = scatter(condInd,corrCoef(condInd));
    scatH(condInd).MarkerEdgeColor = colors(condInd,:);
    scatH(condInd).MarkerFaceColor = colors(condInd,:);
end

%plot shuffle
for condInd = 1:3
    errH = errorbar(condInd,shuffleCorrCoef(condInd,1),...
        shuffleCorrCoef(condInd,2),shuffleCorrCoef(condInd,3));
    errH.Color = colors(condInd,:);
    errH.LineWidth = 2;
    errH.LineStyle = 'none';
end

%set labels
axCorrCoef.XTick = 1:3;
axCorrCoef.XTickLabel = {'All Trials','Left Net Evidence','Right Net Evidence'};
axCorrCoef.YLabel.String = 'Squared Correlation Coefficient';
axCorrCoef.XLabel.String = 'Segment Number';
axCorrCoef.Title.String = 'R^2';

%% Guess vs actual
axGuessVsActual = subplot(2,2,3);
hold(axGuessVsActual,'on');

uniqueVals = unique(classOut(1).testClass);
meanVal = nan(1,length(uniqueVals));
stdVal = nan(size(meanVal));
for i = 1:length(uniqueVals)
    meanVal(i) = mean(classOut(1).guess(classOut(1).testClass==uniqueVals(i)));
    stdVal(i) = std(classOut(1).guess(classOut(1).testClass==uniqueVals(i)));
end

scatH = errorbar(uniqueVals,meanVal,stdVal);
scatH.MarkerEdgeColor = 'b';
scatH.MarkerFaceColor = 'b';
scatH.Color = 'b';
scatH.Marker = 'o';
scatH.LineStyle = 'none';
scatH.MarkerSize = 10;
scatH.LineWidth = 2;

%plot unity line 
plot([-nSeg nSeg], [-nSeg nSeg],'k--');
axis square;

switch lower(classOut(1).classMode)
    case 'netev'
        axGuessVsActual.Title.String = 'Mean Guess vs. actual net evidence';
        axGuessVsActual.XLabel.String = 'Actual Net Evidence';
        axGuessVsActual.YLim = [-nSeg nSeg];
        axGuessVsActual.XLim = [-nSeg nSeg];
    case 'numleft'
        axGuessVsActual.Title.String = 'Mean Guess vs. actual num left';
        axGuessVsActual.XLabel.String = 'Actual Num Left';
        axGuessVsActual.YLim = [0 nSeg];
        axGuessVsActual.XLim = [0 nSeg];
    case 'numright'
        axGuessVsActual.Title.String = 'Mean Guess vs. actual num right';
        axGuessVsActual.XLabel.String = 'Actual Num Right';
        axGuessVsActual.YLim = [0 nSeg];
        axGuessVsActual.XLim = [0 nSeg];
end

axGuessVsActual.YLabel.String = 'Mean Guess';


%% Fit MSE

axGuessVsActualMSE = subplot(2,2,4);
hold(axGuessVsActualMSE,'on');
colors = distinguishable_colors(3);

%plot actual data for mse
scatH = gobjects(1,3);
for condInd = 1:3
    %get absolute difference
    absDiff = abs(classOut(condInd).guess - classOut(condInd).testClass);
    
    %take mean of squares
    mse = mean(absDiff.^2);
    
    scatH(condInd) = scatter(condInd,mse);
    scatH(condInd).MarkerEdgeColor = colors(condInd,:);
    scatH(condInd).MarkerFaceColor = colors(condInd,:);
end

%plot shuffle
for condInd = 1:3
    
    %get absolute difference
    guessDiff = classOut(condInd).shuffleGuess - classOut(condInd).shuffleTestClass;
    
    %take mean of squares
    mse = squeeze(mean(guessDiff.^2))';
    shuffleMed = median(mse);
    confInt = prctile(mse,[lowConf, highConf]);
    confInt = abs(confInt - shuffleMed);
    
    errH = errorbar(condInd,shuffleMed,...
        confInt(1),confInt(2));
    errH.Color = colors(condInd,:);
    errH.LineWidth = 2;
    errH.LineStyle = 'none';
end

%set labels
axGuessVsActualMSE.XTick = 1:3;
axGuessVsActualMSE.XTickLabel = {'All Trials','Left Net Evidence','Right Net Evidence'};
axGuessVsActualMSE.YLabel.String = 'Mean Squared Error';
axGuessVsActualMSE.Title.String = 'Guess vs. actual MSE';

maxfig(figH,1);
