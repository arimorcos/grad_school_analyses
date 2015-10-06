function plotOverlapCorrCoefVsDeltaPLeft(out)
%plotOverlapCorrCoefVsDeltaPLeft.m Plots the output of
%calcOverlapCorrCoefVsDeltaPLeft in two plots for all points together
%
%INPUTS
%out - output of calcOverlapCorrCoefVsDeltaPLeft
%
%OUTPUTS
%
%ASM 10/15

noiseScale = 0.01;

%% plot overlap 

figH = figure;
axOverlap = subplot(1,2,1);
hold(axOverlap,'on');

%concatenate 
startEpoch = 1;
endEpoch = 10;
deltaPLeft = cat(1, out.deltaPLeft{startEpoch:endEpoch});
overlap = cat(1, out.overlap{startEpoch:endEpoch});
corr = cat(1, out.corr{startEpoch:endEpoch});

%define xVals 
xVals = 0:0.01:1;

%fit model
lm = fitlm(deltaPLeft, overlap);

%get yhat
yhat = predict(lm, xVals');

%scatter plot 
scatOverlap = scatter(deltaPLeft + noiseScale*randn(size(deltaPLeft)),...
    overlap + noiseScale*randn(size(deltaPLeft)));

%plot
plotOverlap = plot(xVals, yhat);

beautifyPlot(figH, axOverlap);

%label
axOverlap.XLabel.String = '\Delta p(Left)';
axOverlap.YLabel.String = 'Overlap index';

%print 
fprintf('Overlap vs. delta p(left), Rsquared: %.3f, p: %.3f \n',...
    lm.Rsquared.Ordinary, lm.coefTest);


%% correlation 
axCorr = subplot(1,2,2);
hold(axCorr,'on');

%fit model
lm = fitlm(deltaPLeft, corr);

%get yhat
yhat = predict(lm, xVals');

%scatter plot 
scatCorr = scatter(deltaPLeft + noiseScale*randn(size(deltaPLeft)),...
    corr + noiseScale*randn(size(deltaPLeft)));

%plot
plotCorr = plot(xVals, yhat);

beautifyPlot(figH, axCorr);

%label
axCorr.XLabel.String = '\Delta p(Left)';
axCorr.YLabel.String = 'Correlation coefficient';

%print 
fprintf('Correlation vs. delta p(left), Rsquared: %.3f, p: %.3f \n',...
    lm.Rsquared.Ordinary, lm.coefTest);
