function extIntStruc =...
    quantifyExtIntVariability(dataCell,varargin)
%quantifyExtIntVariability.m Quantifies the ratio of variability due to
%external and internal factors at each segment
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OPTIONAL INPUTS
%variabilityMetric - Options are 'fracMode', for fraction of trials in mode
%   cluster, and 'aucCDF' for area under cdf curve
%
%
%OUTPUTS
%ratio - nSeg x 1 array of ratio for each segment
%absExt - absolute external values
%absInt - absolute internal values
%
%ASM 4/15

shouldShuffle = true;
nShuffles = 200;
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'shouldshuffle'
                shouldShuffle = varargin{argInd+1};
            case 'nshuffles'
                nShuffles = varargin{argInd+1};
        end
    end
end

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%get tracs
[~,traces] = catBinnedTraces(dataCell);

%get nNeurons
nTrials = size(traces,3);

%get mazePatterns
mazePatterns = getMazePatterns(dataCell);
nSeg = size(mazePatterns,2);

%%%%%%%%% Create matrix of values at each point in the maze

tracePoints = getMazePoints(traces,yPosBins);
nPoints = nSeg + 1;
tracePoints = tracePoints(:,1:nPoints,:);

%%%%%%%%%%%% cluster
clusterIDs = nan(nTrials,nPoints);
for point = 1:nPoints
    clusterIDs(:,point) = apClusterNeuronalStates(squeeze(tracePoints(:,point,:)));
end

%%%%% calculate variabilities
[ratio,absExt,absInt,absExtSameSeg] = calculateExtIntVariability(nSeg, clusterIDs, mazePatterns);

%store 
extIntStruc.ratio = ratio;
extIntStruc.absExt = absExt;
extIntStruc.absInt = absInt;
extIntStruc.absExtSameSeg = absExtSameSeg;

%%%% shuffle 
if shouldShuffle
    
    shuffleAbsInt = nan(nShuffles,nSeg);
    shuffleAbsExt = nan(nShuffles,nSeg);
    shuffleRatio = nan(nShuffles,nSeg);
    shuffleAbsExtSameSeg = nan(nShuffles,nSeg);
    for shuffleInd = 1:nShuffles
        
        %shuffle mazePatterns 
        shufflePatterns = mazePatterns(shuffleArray(1:nTrials),:);
        
        %get values 
        [shuffleRatio(shuffleInd,:),shuffleAbsExt(shuffleInd,:),shuffleAbsInt(shuffleInd,:),...
            shuffleAbsExtSameSeg(shuffleInd,:)] = ...
            calculateExtIntVariability(nSeg, clusterIDs, shufflePatterns);
        
        %display progress
        dispProgress('Calculating shuffled values %d/%d',shuffleInd,shuffleInd,nShuffles);
    end
    
    %store 
    extIntStruc.shuffleAbsInt = shuffleAbsInt;
    extIntStruc.shuffleAbsExt = shuffleAbsExt;
    extIntStruc.shuffleRatio = shuffleRatio;
    extIntStruc.shuffleAbsExtSameSeg = shuffleAbsExtSameSeg;
end

end

function [ratio,absExt,absInt,absExtSameSeg] = calculateExtIntVariability(nSeg, clusterIDs,...
    mazePatterns)

%% calculate variabilities

%initialize variabilities
absInt = nan(nSeg,1);
absExt = nan(nSeg,1);
absExtSameSeg = nan(nSeg,1);

%%%%% calculate external variability

%loop through each segment
for segInd = 1:nSeg
    
    %get unique clusters
    uniqueStartClust = unique(clusterIDs(:,segInd));
    nStart = length(uniqueStartClust);
    
    %initialize and loop through each cluster
    extPairs = cell(nStart,1);
    for startClust = 1:nStart
        %find all the trial indices in the matching cluster
        matchClust = find(clusterIDs(:,segInd) == uniqueStartClust(startClust));
        if length(matchClust) == 1 %skip if only one value in starting cluster
            continue;
        end
        
        %loop through each trial pair and add end variability if opposite
        %marginal segment
        pairEndClusters = nan(nchoosek(length(matchClust),2),2);
        totalInd = 1;
        for rowInd = 1:length(matchClust)
            for colInd = rowInd+1:length(matchClust)
                
                if mazePatterns(matchClust(rowInd),segInd) ~=...
                        mazePatterns(matchClust(colInd),segInd) %if opposite marginal segment
                    
                    pairEndClusters(totalInd,:) = [clusterIDs(matchClust(rowInd),segInd+1) ...
                        clusterIDs(matchClust(colInd),segInd+1)];
                    totalInd = totalInd + 1;
                    
                end
                
            end
        end
        %remove extra nans
        pairEndClusters(totalInd:end,:) = [];
        
        %store pairs
        extPairs{startClust} = pairEndClusters;
    end
    
    %concatenate all external pairs
    allExtPairs = cat(1,extPairs{:});
    
    %calculate fraction of pairs in same ending cluster
    diffEndCluster = allExtPairs(:,1) ~= allExtPairs(:,2);
    absExt(segInd) = sum(diffEndCluster)/size(allExtPairs,1);
    
end

%%%% calculate internal variability
netEvidence = getNetEvidence(mazePatterns);
netEvidence = cat(2,zeros(size(mazePatterns,1),1),netEvidence);
for segInd = 1:nSeg
    
    % take all trial pairs 
    nTrials = size(mazePatterns,1);
    allPairs = allcomb(1:nTrials,1:nTrials);
    allPairs(allPairs(:,2) <= allPairs(:,1),:) = [];
    
    %get same cluster pairs 
    pairClusters = [clusterIDs(allPairs(:,1),1) clusterIDs(allPairs(:,2),1)];
    sameCluster = pairClusters(:,1) == pairClusters(:,2);
    
    %delete same cluster pairs 
    diffClusterPairs = allPairs;
    diffClusterPairs(sameCluster,:) = [];
    
    %get current net evidence 
    currNetEv = netEvidence(:,segInd);
    
    %get cluster pairs with the same net evidence 
    clusterNetEv = [currNetEv(diffClusterPairs(:,1)) currNetEv(diffClusterPairs(:,2))];
    sameNetEv = clusterNetEv(:,1) == clusterNetEv(:,2);
    sameNetEvDiffClusterPairs = diffClusterPairs(sameNetEv,:);
    
    %get pairs with the same marginal segment 
    clusterMarginalSeg = [mazePatterns(sameNetEvDiffClusterPairs(:,1),segInd) ...
        mazePatterns(sameNetEvDiffClusterPairs(:,2),segInd)];
    sameMarginalSeg = clusterMarginalSeg(:,1) == clusterMarginalSeg(:,2);
    sNetEvSMargSegDClusterPairs = sameNetEvDiffClusterPairs(sameMarginalSeg,:);
    
    % get the ending cluster for each pair 
    intPairs = [clusterIDs(sNetEvSMargSegDClusterPairs(:,1),segInd+1) ...
        clusterIDs(sNetEvSMargSegDClusterPairs(:,2),segInd+1)];
    
    %calculate fraction of pairs in different ending cluster
    diffEndCluster = intPairs(:,1) ~= intPairs(:,2);
    absInt(segInd) = sum(diffEndCluster)/size(intPairs,1);
    
end

%% calculate external for same segment 

%loop through each segment
for segInd = 1:nSeg
    
    %get unique clusters
    uniqueStartClust = unique(clusterIDs(:,segInd));
    nStart = length(uniqueStartClust);
    
    %initialize and loop through each cluster
    extPairs = cell(nStart,1);
    for startClust = 1:nStart
        %find all the trial indices in the matching cluster
        matchClust = find(clusterIDs(:,segInd) == uniqueStartClust(startClust));
        if length(matchClust) == 1 %skip if only one value in starting cluster
            continue;
        end
        
        %loop through each trial pair and add end variability if opposite
        %marginal segment
        pairEndClusters = nan(nchoosek(length(matchClust),2),2);
        totalInd = 1;
        for rowInd = 1:length(matchClust)
            for colInd = rowInd+1:length(matchClust)
                
                if mazePatterns(matchClust(rowInd),segInd) ==...
                        mazePatterns(matchClust(colInd),segInd) %if same marginal segment
                    
                    pairEndClusters(totalInd,:) = [clusterIDs(matchClust(rowInd),segInd+1) ...
                        clusterIDs(matchClust(colInd),segInd+1)];
                    totalInd = totalInd + 1;
                    
                end
                
            end
        end
        %remove extra nans
        pairEndClusters(totalInd:end,:) = [];
        
        %store pairs
        extPairs{startClust} = pairEndClusters;
    end
    
    %concatenate all external pairs
    allExtPairs = cat(1,extPairs{:});
    
    %calculate fraction of pairs in same ending cluster
    diffEndCluster = allExtPairs(:,1) ~= allExtPairs(:,2);
    absExtSameSeg(segInd) = sum(diffEndCluster)/size(allExtPairs,1);
    
end

%calculate ratio 
ratio = absExt./absInt;

end




