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

%%% MSE
axMSE = subplot(2,1,1);
hold(axMSE,'on');
colors = distinguishable_colors(3);

%plot actual data for mse
xVal = 1:nSeg;
for condInd = 1:3
    scatH = scatter(xVal + (condInd-1)*0.2,mse(:,condInd));
    scatH.MarkerEdgeColor = colors(condInd,:);
    scatH.MarkerFaceColor = colors(condInd,:);
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

%%%%% CorrCoef 
axCorrCoef = subplot(2,1,2);
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

% add legend 
legend(scatH,{'All Conditions','Left Conditions','Right Conditions'},...
    'Location','Best');