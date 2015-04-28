function plotTransientStats(stats)
%plotTransientStats.m Plots histograms of nTransients for 20 random neurons
%and plots histograms for mean length and fraction of length
%
%INPUTS
%stats - stats output by getTransientStats
%
%ASM 10/14

%% plot inidividual neuron histograms

%get nNeurons
% nNeurons = length(stats.meanTransLength);
% 
% %select 20 random neurons
% randNeurons = randperm(nNeurons,20);
% 
% %get max lim
% tempAll = stats.nTransientsAll(randNeurons,:);
% newXLim = [min(tempAll(:))-0.5 max(tempAll(:))+0.5];
% 
% %loop through and create histograms
% figure;
% for i = 1:20
%     subplot(4,5,i);
%     histogram(stats.nTransientsAll(randNeurons(i),:));
%     set(gca,'xlim',newXLim);
% end
% 
% suplabel('Number of transients histograms for individual neurons','t');
% suplabel('Number of Transients','x');
% suplabel('Count','y');

%% plot individual histograms for special features
figure;

%plot meanNTransients
ax1 = subplot(1,3,1);
histogram(stats.meanNTransients,20,'Normalization','probability');
xlabel('# Transients');
ylabel('Fraction of active neurons');
title('Mean # Transients');
ax1.FontSize = 20;
ax1.LabelFontSizeMultiplier = 1.5;

%plot mean transient length (in sec)
ax2 = subplot(1,3,2);
histogram(stats.meanTransLength,20,'Normalization','probability');
xlabel('Transient Length (sec)');
title('Mean Transient Length (sec)');
ax2.FontSize = 20;
ax2.LabelFontSizeMultiplier = 1.5;

%plot mean transient fraction 
ax3 = subplot(1,3,3);
histogram(stats.meanFracLength,20,'Normalization','probability');
xlabel('Fraction of trial active');
title('Mean trial fraction active');
ax3.FontSize = 20;
ax3.LabelFontSizeMultiplier = 1.5;