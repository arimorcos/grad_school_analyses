function [posInfo, netEvInfo] = calcMutualInfoPosNetEv(dataCell)
%calcMutualInfoPosNetEv.m Calculates mutual information between position
%activity and net evidence and activity
%
%INPUTS
%dataCell - dataCell containing imagin and integration data
%
%ASM 12/14

%get segment traces
[segTraces,~,netEv] = extractSegmentTraces(dataCell,'useBins',true);

%get size
[nNeurons,nBinsPerSeg,~] = size(segTraces);

%get unique net evidence conditions
[uniqueNetEv,netEvCounts] = count_unique(netEv); %get unique elements and counts
nNetEv = length(uniqueNetEv);

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%initialize
posInfo = zeros(nNeurons,1);
netEvInfo = zeros(nNeurons,1);

opts.method = 'gs';
opts.bias = 'qe';
opts.btsp = 100;
opts.xtrp = 3;

%loop through each neuron and calculate mutual info
for neuronInd = 1:nNeurons
    
    %disp progress
    dispProgress('Calculating mutual information for neuron %d/%d',neuronInd,neuronInd,nNeurons);
    
    %construct input matrix
    [R, nt] = buildr(netEv, squeeze(segTraces(neuronInd,:,:)));
    R = binr(R, nt, 200,'eqpop');
    opts.nt = nt;
    
    %calculate mutual information for net ev
    IPos = information(R,opts,'ish');
    
%     posInfo(neuronInd) = mutualinfo(neuronVec,posVec);
    netEvInfo(neuronInd) = IPos(1);
    
end


%initialize
% neuronInfoInputMat = nan(nNeurons,nBinsPerSeg,max(netEvCounts),nNetEv);

% %loop through each net evidence condition
% for netEvCond = 1:nNetEv
%     
%     %store those trials
%     neuronInfoInputMat(:,:,1:netEvCounts(netEvCond),netEvCond) = ...
%         segTraces(:,:,netEv == uniqueNetEv(netEvCond));
%     
% end

% 
% %remove negative values
% neuronInfoInputMat = neuronInfoInputMat + abs(min(neuronInfoInputMat(:))) + 1; %add the minimum value plus 1 to everything so that the lowest value is 1
% 
% %convert to integers 
% neuronInfoInputMat = round(1e4*neuronInfoInputMat);


% assignin('base','R',R);
%calculate mutual information
% keyboard;


