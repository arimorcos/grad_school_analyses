function plotMultipleAcrossEpochCorrVsTransProbScatter(folder,fileStr)
%plotMultipleAcrossEpochCorrVsTransProb.m Plots the across epoch
%correlation for clusters vs. the transition probability
%
%ASM 10/15

%get list of files in folder
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));
nFiles = length(matchFiles);

%loop through each file and create array
allOverlapIndex = cell(nFiles,1);
allDeltaEpochs = cell(nFiles,1);
allClusterCorr = cell(nFiles,1);
allTransMat = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    allDeltaEpochs{fileInd} = currFileData.deltaEpochs;
    allClusterCorr{fileInd} = currFileData.clusterCorr;
    allTransMat{fileInd} = currFileData.transMat;
    allOverlapIndex{fileInd} = currFileData.overlapIndex;
end

%% loop throug and process
allDeltaEpochVec = [];
allTransMatVec = [];
allClusterCorrVec = [];
for file = 1:nFiles
    
    overlapIndex = allOverlapIndex{file};
    transMat = allTransMat{file};
    deltaEpochs = allDeltaEpochs{file};
    clusterCorr = allClusterCorr{file};
    
    % convert everything to triangular matrix
    nTotal = length(overlapIndex);
    nanInd = ~logical(triu(ones(nTotal),1));
    overlapIndex(nanInd) = NaN;
    clusterCorr(nanInd) = NaN;
    deltaEpochs(nanInd) = NaN;
    
    % convert to vectors
    overlapVec = overlapIndex(:);
    clusterCorrVec = clusterCorr(:);
    deltaEpochVec = deltaEpochs(:);
    transMatVec = transMat(:);
    
    % filter
    removeInd = nanInd(:);
    overlapVec(removeInd) = [];
    clusterCorrVec(removeInd) = [];
    deltaEpochVec(removeInd) = [];
    transMatVec(removeInd) = [];
    
    allClusterCorrVec = cat(1, allClusterCorrVec, clusterCorrVec);
    allTransMatVec = cat(1, allTransMatVec, transMatVec);
    allDeltaEpochVec = cat(1, allDeltaEpochVec, deltaEpochVec);   
    
end


% filter epoch 
which_epoch = 1;
keep_ind = allDeltaEpochVec == which_epoch;
allTransMatVec = allTransMatVec(keep_ind);
allClusterCorrVec = allClusterCorrVec(keep_ind);

%% plot
figH = figure;
axH = axes; 

hold(axH, 'on');

% plot scatter
scatH = scatter(allTransMatVec, allClusterCorrVec);

%beautify
beautifyPlot(figH, axH);

%label
axH.XLabel.String = 'Transition probability';
axH.YLabel.String = 'Mean cluster-cluster correlation';


