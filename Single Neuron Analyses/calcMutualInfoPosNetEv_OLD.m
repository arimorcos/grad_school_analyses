function [posInfo, netEvInfo, segIDInfo] = calcMutualInfoPosNetEv_OLD(dataCell)
%calcMutualInfoPosNetEv.m Calculates mutual information between position
%activity and net evidence and activity
%
%INPUTS
%dataCell - dataCell containing imagin and integration data
%
%ASM 10/14

%extract neuronal traces
[~,traces] = catBinnedTraces(dataCell);

%get info
[nNeurons,nBins,nTrials] = size(traces);

%range
range = 0:80:480;

%get net evidence
netEv = getNetEvidence(dataCell);
segID = getMazePatterns(dataCell);
nSeg = size(netEv,2);

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%construct net evidence vector
netEvVec = zeros(1,nBins*nTrials);
segIDVec = zeros(1,nBins*nTrials);
for trialInd = 1:nTrials
    
    %get binIndices for trial
    binInd = 1 + (trialInd-1)*nBins:nBins*trialInd;
    
    %create tempBins
    tempBins = zeros(1,nBins);
    tempSegID = zeros(1,nBins);
    
    %loop through each seg
    for segInd = 1:nSeg
        tempBins(yPosBins >= range(segInd) & yPosBins < range(segInd+1)) = netEv(trialInd,segInd);
        tempSegID(yPosBins >= range(segInd) & yPosBins < range(segInd+1)) = segID(trialInd,segInd);
    end
    tempBins(yPosBins >= range(nSeg+1)) = netEv(trialInd,nSeg);
    tempSegID(yPosBins >= range(nSeg+1)) = segID(trialInd,nSeg);
    
    %assign to netEvVec
    netEvVec(binInd) = tempBins;
    segIDVec(binInd) = tempSegID;
        
end

%construct pos vector
posVec = repmat(yPosBins,1,nTrials);

%initialize
posInfo = zeros(nNeurons,1);
netEvInfo = zeros(nNeurons,1);
segIDInfo = zeros(nNeurons,1);

%throw out netEv vals > +-4 
% oldNetEvVec = netEvVec;
% posVec(abs(oldNetEvVec) > 4) = [];
% netEvVec(abs(oldNetEvVec) > 4) = [];

%loop through each neuron and calculate mutual info
for neuronInd = 1:nNeurons

    %create neruon vector
    neuronVec = reshape(traces(neuronInd,:,:),1,[]);
    neuronVec = neuronVec + abs(min(min(neuronVec),0));
    neuronVec = neuronVec/max(neuronVec);
    
    %throw out vals > 4 
%     neuronVec(abs(oldNetEvVec)>4)=[];
    
    %calculate mutual information
%     posInfo(neuronInd) = mutualinfo(neuronVec,posVec);
%     netEvInfo(neuronInd) = mutualinfo(neuronVec,netEvVec);
    segIDInfo(neuronInd) = mutualinfo(neuronVec,segIDVec);
    
end


