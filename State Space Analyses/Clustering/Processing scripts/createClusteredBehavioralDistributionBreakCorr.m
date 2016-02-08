%saveFolder 
saveFolder = '/mnt/7A08079708075215/DATA/Analyzed Data/160202_vogel_netEvBehavDist_breakCorr';

%get list of datasets 
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
    
    %get net evidence
    netEv = getNetEvidence(imTrials);
    
    %cluster 
    range = [0.5, 0.75];
    perc = 10;
    nPoints = 10;
    yPosBins = imTrials{1}.imaging.yPosBins;
    traces = catBinnedDeconvTraces(imTrials);
    tracePoints = getMazePoints(traces,yPosBins,range);
    nTrials = size(traces,3);
    num_neurons = size(traces, 1);
    clusterIDs = nan(nTrials,nPoints);
    for point = 1:nPoints
        % shuffle net evidence independently for each neuron
        if point >= 2 && point <= 7
            unique_net_ev = unique(netEv(:, point-1));
            num_unique_net_ev = length(unique_net_ev);
            for ev = 1:num_unique_net_ev
                match_ind = find(netEv(:, point-1) == unique_net_ev(ev));
                for neuron = 1:num_neurons
                    tracePoints(neuron, point, match_ind) = ...
                        tracePoints(neuron, point, shuffleArray(match_ind));
                end
            end
        end
        clusterIDs(:,point) = apClusterNeuronalStates(squeeze(tracePoints(:,point,:)), perc);
    end
    
    %get behavioral distribution
    for i = 2:7
        outBreakCorr{i-1} = clusterBehavioralDistribution(clusterIDs(:,i),netEv(:,i-1));
    end
    
    %cluster 
    [~,~,clusterIDs,~] = getClusteredMarkovMatrix(imTrials);
    
    %get behavioral distribution
    for i = 2:7
        out{i-1} = clusterBehavioralDistribution(clusterIDs(:,i),netEv(:,i-1));
    end
    
    
    %save 
    saveName = fullfile(saveFolder,sprintf('%s_%s_netEvClusterBehavDistBreakCorr.mat',procList{dSet}{:}));
    save(saveName,'out','outBreakCorr');
end