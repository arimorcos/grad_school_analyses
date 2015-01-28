function figHandle = plotLeftRightSelectivity(selectivity,sig,bins,shouldSort)
%plotLeftRightSelectivity.m Plots output of leftRightSelectivity
%
%INPUTS
%selectivity - nNeurons x nBins array of selectivity indices
%sig - nNeurons x nBins logical array of significance
%
%OUTPUTS
%figHandle - figure handle
%
%ASM 1/14

%create figure
figHandle = figure;

if shouldSort
    %sort by peak selectivity
    [~,peakInd] = max(abs(selectivity),[],2);
    [~,sortInd] = sort(peakInd);
    selectivity = selectivity(sortInd,:);
    sig = sig(sortInd,:);
end

%create selectivity plot
subplot(2,1,1);
imagesc(bins,1:size(selectivity),selectivity);
cAxis = colorbar;
xlabel('Y Position (binned)');
ylabel('Cell # (sorted)');
title('Selectivity Index');
set(get(cAxis,'Label'),'String','Selectivity Index');
axis square;

%create significance plot
subplot(2,1,2);
imagesc(bins,1:size(sig),sig);
cAxis = colorbar;
xlabel('Y Position (binned)');
ylabel('Cell # (sorted)');
title('Significant');
set(get(cAxis,'Label'),'String','Significance');
axis square;
