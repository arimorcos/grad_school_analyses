function plotOverlapCorrCoefVsDeltaPLeftPointwise(out)
%plotOverlapCorrCoefVsDeltaPLeftPointwise.m Plots the output of
%calcOverlapCorrCoefVsDeltaPLeft in two plots for each point
%
%INPUTS
%out - output of calcOverlapCorrCoefVsDeltaPLeft
%
%OUTPUTS
%
%ASM 10/15

%% plot overlap 

figH = figure;
axOverlap = subplot(1,2,1);
hold(axOverlap,'on');

%get nPoints
nPoints = length(out.deltaPLeft);

% define colors
colors = jet(nPoints);

%define xVals 
xVals = 0:0.01:1;

%loop through points and plot 
for point = 1:nPoints
    
    % fit trendline 
    lm = fitlm(out.deltaPLeft{point}, out.overlap{point});
    
    %plot trend line 
    yhat = predict(lm, xVals');
    plotH = plot(xVals, yhat);
    plotH.Color = colors(point,:); 
    
end

beautifyPlot(figH, axOverlap);

%label
axOverlap.XLabel.String = '\Delta p(Left)';
axOverlap.YLabel.String = 'Overlap index';

