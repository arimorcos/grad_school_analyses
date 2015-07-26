function netEvInd = getNetEvidenceSelectivity(dataCell,shouldShuffle)
%getNetEvidenceSelectivity.m Calculates the net evidence selectivity for
%each cell by taking the difference between activity at the preferred net
%evidence and average activity at all others divided by the sum. Thus, the
%index ranges from 0 to 1.
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%netEvInd - nCells x 1 array of net evidence indices.
%
%ASM 7/15

range = [0.5 0.75];
if nargin < 2 || isempty(shouldShuffle)
    shouldShuffle = false;
end

%extract segment traces
[segTraces,~,netEv,~,~,~] = extractSegmentTraces(dataCell,'usebins',true,...
    'tracetype','dFF');

%get nNeurons
[nNeurons,nBinsPerSeg,~] = size(segTraces);

%take mean of each segment trace across range
meanBinRange = round(range*nBinsPerSeg);
segTraces = mean(segTraces(:,meanBinRange(1):meanBinRange(2),:),2);

%shuffle 
if shouldShuffle 
    for neuron = 1:nNeurons
        segTraces(neuron,:,:) = shuffleArray(segTraces(neuron,:,:));
    end
end

%get unique net evidence conditions
uniqueNetEv = unique(netEv);
nNetEv = length(uniqueNetEv);

%initialize
actNetEv = zeros(nNetEv,nNeurons);

%loop through each net ev condition
for condInd = 1:nNetEv
    
    %get subset containing only trials with that net ev condition
    traceSub = segTraces(:,:,netEv == uniqueNetEv(condInd));
    
    %take mean for each neuron and store
    actNetEv(condInd,:) = nanmean(traceSub,3)';
    
end

%initialize netEvInd 
netEvInd = nan(nNeurons,1);

for neuron = 1:nNeurons
    
    %offset if necessary 
    if min(actNetEv(:,neuron)) < 0 
        actNetEv(:,neuron) = actNetEv(:,neuron) + abs(min(actNetEv(:,neuron)));
    end
    
   [prefVal,prefInd] = max(actNetEv(:,neuron)); 
   nonPrefInd = setdiff(1:nNetEv,prefInd);
   nonPrefVal = mean(actNetEv(nonPrefInd,neuron));
   
   %calculate index 
   netEvInd(neuron) = (prefVal - nonPrefVal)/(prefVal + nonPrefVal);
end