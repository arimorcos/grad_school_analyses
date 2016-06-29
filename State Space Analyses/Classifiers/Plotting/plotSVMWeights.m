function plotSVMWeights(sel_ind, weights)

use_abs = true;

figH = figure;
axH = axes;

if use_abs
    weights = abs(weights);
end

hold(axH, 'on');

scatH = scatter(weights, sel_ind);

axH.XLim(1) = axH.XLim(1) - 0.1*range(axH.XLim);

mdl = fitlm(weights, sel_ind);
fit_x = linspace(axH.XLim(1), axH.XLim(2), 10)';
fit_y = mdl.predict(fit_x);
lineH = plot(fit_x, fit_y);
lineH.LineWidth = 2;
lineH.Color = 'k';

[r, p] = corrcoef(weights, sel_ind);
r = r(2,1);
p = p(2,1);


corr_str = sprintf('r = %.3f | p = %.3f', r, p);
textH = text(axH.XLim(2)- 0.02*range(axH.XLim), ...
    axH.YLim(2) - 0.02*range(axH.YLim), corr_str);
textH.HorizontalAlignment = 'right';
textH.VerticalAlignment = 'top';

beautifyPlot(figH, axH);

if use_abs
    axH.XLabel.String = '|SVM weights|';
else
    axH.XLabel.String = 'SVM weights';
end
axH.YLabel.String = '|Choice selectivity index|';
