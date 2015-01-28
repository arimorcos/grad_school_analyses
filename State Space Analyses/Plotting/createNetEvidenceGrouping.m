function [groups,dFFData,PCAData] = createNetEvidenceGrouping(dataCell,...
    unPerEv,unPerBin,evStart)
%[data,groups] = createNetEvidenceGrouping(dataCell) Function to create
%grouping matrix to sort data based on net evidence accumulated (left -
%right). Requires dataCell with imaging data
%
%INPUTS
%dataCell - dataCell with imaging data
%unPerEv - units per piece of evidence. Defaults to 80
%unPerBin - units per bin. Defaults to 10
%evStart - start of evidence. Defaults to 0
%
%OUTPUTS
%groups - nTrials x nBins x nNeurons grouping matrix containing the values
%   -nSeg:nSeg indicating evidence accumulated at each trial/bin combination 
%dFFData - nTrials x nBins x nNeurons matrix of dFF data
%PCAData - nTrials x nBins x nNeurons matrix of PCA data
%
%ASM 11/13

if nargin < 4 || isempty(evStart)
    evStart = 0;
end
if nargin < 3 || isempty(unPerBin)
    unPerBin = 10;
end
if nargin < 2 || isempty(unPerEv)
    unPerEv = 80;
end

%ensure contains imaging data
if ~isfield(dataCell{1},'imaging') || sum(findTrials(dataCell,'imaging.imData == 1')) == 0
    error('dataCell must contain imaging data');
end

%get imaging subset
imSub = getTrials(dataCell,'imaging.imData == 1');

%bin if necessary
if ~isfield(imSub{1}.imaging,'binnedDFFTraces')
    imSub = binFramesByYPos(imSub,10);
end

%extract data
[dFFData,PCAData] = catBinnedTraces(imSub);

%permute axes from nNeurons x nBins x nTrials TO nTrials x nBins x nNeurons
dFFData = permute(dFFData,[3 2 1]);
PCAData = permute(PCAData,[3 2 1]);

%get size
[nTrials, nBins, nNeurons] = size(dFFData);

%get yPosBins
yPosBins = imSub{1}.imaging.yPosBins;

%get maze pattterns
mazePatterns = getMazePatterns(dataCell);

%replace 0s with -1s in mazePatterns 
mazePatterns(mazePatterns == 0) = -1;

%get nSeg
nSeg = size(mazePatterns,2);

%take cumsum
netEvidence = cumsum(mazePatterns,2);

%generate bin pattern ( 1 x nBins matrix of which segment at each bin)
binPattern = zeros(1,nBins);
patternRange = evStart:unPerEv:unPerEv*nSeg;
patternRange(end) = patternRange(end)*1000;
for i = 1:nSeg 
    binPattern(yPosBins >= patternRange(i) & yPosBins < patternRange(i+1)) = i;
end

%create grouping matrix 
groups = repmat(binPattern,nTrials,1);
for i = 1:nSeg
    for j = 1:nTrials
        groups(j,groups(j,:) == i) = netEvidence(j,i);
    end
end

%replicate groups
groups = repmat(groups,1,1,nNeurons);

