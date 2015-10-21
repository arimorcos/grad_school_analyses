function stats = getSimpleTransStats(dataCell)

%get traces 
traces = catBinnedDeconvTraces(dataCell);

[nNeurons, nBins, nTrials] = size(traces);
cueInd = dataCell{1}.imaging.yPosBins >= 0 &...
    dataCell{1}.imaging.yPosBins < 480;

fracActive = cell(nNeurons,1);
fracCueActive = cell(nNeurons,1);

% loop through each trial
for trial = 1:nTrials
    
    %loop through each neuron 
    for neuron = 1:nNeurons
        
        tempTraceAll = traces(neuron,:,trial);
        tempTraceLim = traces(neuron,cueInd,trial);
        tempTraceAll(tempTraceAll < 0.01) = 0;
        tempTraceLim(tempTraceLim < 0.01) = 0;
        
        %get fraction of trial active 
        if any(tempTraceAll)        
            fracActive{neuron} = cat(1,fracActive{neuron},nansum(tempTraceAll ~= 0)/length(tempTraceAll));
        end
        if any(tempTraceLim)
            fracCueActive{neuron} = cat(1,fracCueActive{neuron},nansum(tempTraceLim ~= 0)/length(tempTraceLim));
        end        
    end
    
end

%take means 
stats.meanFracActive = cellfun(@nanmean, fracActive);
stats.stdFracActive = cellfun(@nanstd, fracActive);
stats.meanFracCueActive = cellfun(@nanmean, fracCueActive);
stats.stdFracCueActive = cellfun(@nanstd, fracCueActive);