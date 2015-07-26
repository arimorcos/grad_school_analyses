%% abs version 
%get peak of each cell 
peakAbsVal = cellfun(@(x) max(abs(x),[],2),selIndAll,'Uniformoutput',false);
peakAbsVal = cat(1,peakAbsVal{:});

% plot 
figH = figure;
axH = axes;
histH = histogram(peakAbsVal,30,'Normalization','probability');

%beautify
beautifyPlot(figH,axH);

%label
axH.XLabel.String = '| Selectivity Index |';
axH.YLabel.String = 'Fraction of Neurons';


%% non-abs version
peakVal = [];
for dset = 1:length(selIndAll)
    [~,ind] = max(abs(selIndAll{dset}),[],2);
    for cell = 1:length(ind)
        peakVal = cat(1,peakVal, selIndAll{dset}(cell,ind(cell)));
    end
end