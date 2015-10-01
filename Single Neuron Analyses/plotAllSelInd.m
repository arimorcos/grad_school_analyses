%% abs version 
%get peak of each cell 
% peakAbsVal = cellfun(@(x) max(abs(x),[],2),selIndAll,'Uniformoutput',false);
peakAbsVal = cellfun(@(x) mean(abs(x),2),selIndAll,'Uniformoutput',false);
peakAbsVal = cat(1,peakAbsVal{:});

%get shuffle
% peakAbsValShuffle = cellfun(@(x) max(abs(x),[],2),shuffleSelIndAll,'Uniformoutput',false);
peakAbsValShuffle = cellfun(@(x) mean(abs(x),2),shuffleSelIndAll,'Uniformoutput',false);
peakAbsValShuffle = cat(1,peakAbsValShuffle{:});

% plot 
figH = figure;
axH = axes;
hold(axH,'on');
minVal = min(cat(1,peakAbsVal,peakAbsValShuffle));
maxVal = max(cat(1,peakAbsVal,peakAbsValShuffle));
nBins = 30;
binEdges = linspace(minVal,maxVal,nBins+1);

%shaded version
% histReal = histogram(peakAbsVal,binEdges,'Normalization','probability');
% histShuffle = histogram(peakAbsValShuffle,binEdges,'Normalization','probability');

%outline version
smooth = false;
histReal = histoutline(peakAbsVal,binEdges,smooth,'Normalization','probability');
histShuffle = histoutline(peakAbsValShuffle,binEdges,smooth,'Normalization','probability');
uistack(histReal,'top');
histReal.LineWidth = 2;
histShuffle.LineWidth = 2;
histShuffle.Color = [0.7 0.7 0.7];

%beautify
beautifyPlot(figH,axH);

%label
axH.XLabel.String = '| Selectivity Index |';
axH.YLabel.String = 'Fraction of Neurons';

%add legend
legH = legend([histReal, histShuffle],{'Real','Shuffled'},'Location','NorthEast');


%% non-abs version
peakVal = [];
for dset = 1:length(selIndAll)
    [~,ind] = max(abs(selIndAll{dset}),[],2);
    for cell = 1:length(ind)
        peakVal = cat(1,peakVal, selIndAll{dset}(cell,ind(cell)));
    end
end