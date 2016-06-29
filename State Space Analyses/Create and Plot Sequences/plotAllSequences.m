
% seqInfo = seqInfoNoNorm;
% seqInfo = seqInfoZScore;
seqInfo = seqInfoCellNorm;

%%
binLengths = cellfun(@(x) length(x.bins),seqInfo);

%get min binlengths 
[minBinLength, ind] = min(binLengths);

%concatenate 
croppedTraces = cellfun(@(x) x.normTraces{1}(:,1:minBinLength),seqInfo,'UniformOutput',false);
allTraces = cat(1,croppedTraces{:});

%resort
[~,maxInd] = max(allTraces,[],2);
[~,sortOrder] = sort(maxInd);
allTraces = allTraces(sortOrder,:);

%cutoff 
cutoff = 3;
allTraces(allTraces > cutoff) = cutoff;

% filter cells 
remove_thresh = 0.7;
remove_cells = mean(allTraces, 2) > remove_thresh;
allTraces(remove_cells, :) = [];

%plot 
figH = plotSequences({allTraces},seqInfo{ind}.bins,...
    seqInfo{1}.conditions,seqInfo{1}.normInd,seqInfo{1}.colorLab,[]);