function figH = plotClassifierOutIndSegSVM(classOut)
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
mse = nan(nSeg,3);
corrCoef = nan(nSeg,3);
shuffleMSE = nan(nSeg,3,3);
shuffleCorrCoef = nan(nSeg,3,3);

%determine confidence interval range
lowConf = (100 - confInt)/2;
highConf = 100 - lowConf;

%loop through each condition
for condInd = 1:3
    
    %store data
    mse(:,condInd) = classOut(condInd).mse;
    corrCoef(:,condInd) = classOut(condInd).corrCoef;
    
    %get confidence intervals
    shuffleMSE(:,condInd,1) = median(classOut(condInd).shuffleMSE,3);
    shuffleMSE(:,condInd,2:3) = prctile(classOut(condInd).shuffleMSE,[lowConf,highConf],3);
    shuffleMSE(:,condInd,2:3) = abs(bsxfun(@minus,shuffleMSE(:,condInd,2:3),shuffleMSE(:,condInd,1)));
    
    shuffleCorrCoef(:,condInd,1) = median(classOut(condInd).shuffleCorrCoef,3);
    shuffleCorrCoef(:,condInd,2:3) = prctile(classOut(condInd).shuffleCorrCoef,[lowConf,highConf],3);
    shuffleCorrCoef(:,condInd,2:3) = abs(bsxfun(@minus,shuffleCorrCoef(:,condInd,2:3),...
        shuffleCorrCoef(:,condInd,1)));
end


%plot 
figH = figure;

%% Model MSE
axMSE = subplot(2,2,1);
hold(axMSE,'on');
colors = distinguishable_colors(3);

%plot actual data for mse
xVal = 1:nSeg;
scatH = gobjects(1,3);
for condInd = 1:3
    scatH(condInd) = scatter(xVal + (condInd-1)*0.2,mse(:,condInd));
    scatH(condInd).MarkerEdgeColor = colors(condInd,:);
    scatH(condInd).MarkerFaceColor = colors(condInd,:);
end

%plot shuffle 
for condInd = 1:3
    errH = errorbar(xVal + (condInd-1)*0.2,shuffleMSE(:,condInd,1),...
        shuffleMSE(:,condInd,2),shuffleMSE(:,condInd,3));
    errH.Color = colors(condInd,:);
    errH.LineStyle = 'none';
end

%set labels 
axMSE.XTick = xVal + 0.3;
axMSE.XTickLabel = xVal;
axMSE.YLabel.String = 'Mean Squared Error';
axMSE.Title.String = 'Model MSE';
axMSE.XLabel.String = 'Segment Number';

% add legend 
legend(scatH,{'All Conditions','Left Conditions','Right Conditions'},...
    'Location','NorthWest');

%% CorrCoef 
axCorrCoef = subplot(2,2,2);
hold(axCorrCoef,'on');
colors = distinguishable_colors(3);

%plot actual data for mse
xVal = 1:nSeg;
scatH = gobjects(1,3);
for condInd = 1:3
    scatH(condInd) = scatter(xVal + (condInd-1)*0.2,corrCoef(:,condInd));
    scatH(condInd).MarkerEdgeColor = colors(condInd,:);
    scatH(condInd).MarkerFaceColor = colors(condInd,:);
end

%plot shuffle 
for condInd = 1:3
    errH = errorbar(xVal + (condInd-1)*0.2,shuffleCorrCoef(:,condInd,1),...
        shuffleCorrCoef(:,condInd,2),shuffleCorrCoef(:,condInd,3));
    errH.Color = colors(condInd,:);
    errH.LineStyle = 'none';
end

%set labels 
axCorrCoef.XTick = xVal + 0.3;
axCorrCoef.XTickLabel = xVal;
axCorrCoef.YLabel.String = 'Squared Correlation Coefficient';
axCorrCoef.XLabel.String = 'Segment Number';
axCorrCoef.Title.String = 'R^2';

%% Guess vs actual 
axGuessVsActual = subplot(2,2,3);
hold(axGuessVsActual,'on');
colors = distinguishable_colors(nSeg);

scatH = gobjects(nSeg,1);
legEnt = cell(nSeg,1);
% loop through each segment and plot
for segInd = 1:nSeg
    
    uniqueVals = unique(classOut(1).testClass(:,segInd));
    meanVal = nan(1,length(uniqueVals));
    for i = 1:length(uniqueVals)
        meanVal(i) = mean(classOut(1).guess(classOut(1).testClass(:,segInd)==uniqueVals(i),segInd));
    end
        
%     scatH = scatter(classOut(1).testClass(:,segInd),classOut(1).guess(:,segInd));
    scatH(segInd) = scatter(uniqueVals,meanVal);
    scatH(segInd).MarkerEdgeColor = colors(segInd,:);
    scatH(segInd).MarkerFaceColor = colors(segInd,:);
    scatH(segInd).SizeData = 100;
    
    legEnt{segInd} = sprintf('Segment %d',segInd);
end

%plot unity line 
plot([-nSeg nSeg], [-nSeg nSeg],'k--');
axis square;

legend(scatH,legEnt,'Location','NorthWest');
axGuessVsActual.YLim = [-nSeg nSeg];
axGuessVsActual.XLabel.String = 'Actual Net Evidence';
axGuessVsActual.YLabel.String = 'Mean Guess';
axGuessVsActual.Title.String = 'Mean Guess vs. actual net evidence';

%% Fit MSE

axGuessVsActualMSE = subplot(2,2,4);
hold(axGuessVsActualMSE,'on');
colors = distinguishable_colors(3);



%plot actual data for mse
xVal = 1:nSeg;
scatH = gobjects(1,3);
for condInd = 1:3
    %get absolute difference 
    absDiff = abs(classOut(condInd).guess - classOut(condInd).testClass);
    
    %take mean of squares 
    mse = mean(absDiff.^2);
    
    scatH(condInd) = scatter(xVal + (condInd-1)*0.2,mse);
    scatH(condInd).MarkerEdgeColor = colors(condInd,:);
    scatH(condInd).MarkerFaceColor = colors(condInd,:);
end

%plot shuffle 
for condInd = 1:3
    
    %get absolute difference 
    absDiff = abs(classOut(condInd).shuffleGuess - classOut(condInd).shuffleTestClass);
    
    %take mean of squares 
    mse = squeeze(mean(absDiff.^2))';
    shuffleMed = median(mse);
    confInt = prctile(mse,[lowConf, highConf]);
    
    errH = errorbar(xVal + (condInd-1)*0.2,shuffleMed,...
        confInt(1,:),confInt(2,:));
    errH.Color = colors(condInd,:);
    errH.LineStyle = 'none';
end

%set labels 
axGuessVsActualMSE.XTick = xVal + 0.3;
axGuessVsActualMSE.XTickLabel = xVal;
axGuessVsActualMSE.XLabel.String = 'Segment Number';
axGuessVsActualMSE.YLabel.String = 'Mean Squared Error';
axGuessVsActualMSE.Title.String = 'Guess vs. actual MSE';
