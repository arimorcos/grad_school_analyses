function plotPredictClusterInternalExternal(out)
%plotPredictclusterInternalExternal.m Plots the output of
%predictClusterIntenralExternal.m 
%
%INPUTS
%out - output of predictclusterInternalExternal
%
%OUTPUTS
%handles - array of handles 
%
%ASM 8/15

%create figure 
figH = figure; 
axH = axes;

%concatenate 
barInfo = cat(1,out.noInformationAcc,out.externalAcc,out.internalAcc,out.bothAcc)';

%multiply by 100 
barInfo = 100*barInfo;

%create barplot 
barH = bar(barInfo);
% colors = lines(5);
% colors(3,:) = [];
% for i = 1:4
%     barH(i).FaceColor = colors(i,:);
% end

%beautify
beautifyPlot(figH,axH);

%label 
axH.XLabel.String = 'Cue number';
axH.YLabel.String = 'Prediction accuracy';

%legend
legH = legend