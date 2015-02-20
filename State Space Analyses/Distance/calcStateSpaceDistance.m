function out = calcStateSpaceDistance(dataCell,conditions,useFactors)
%calcStateSpaceDistance.m Calculates distance between trials of different
%conditions in n-dimensional space
%
%INPUTS
%dataCell - processed dataCell containing binned neuronal data
%conditions - 1 x 2 cell array containing conditions to compare. 1st
%   element will be the intra, second element will be inter. If second
%   element is empty, will compare to all.
%usePCs - use PCs instead of dF/F. Default is false
%
%
%OUTPUTS
%out - structure containing all output data
%
%ASM 11/13

if nargin < 3 || isempty(useFactors)
    useFactors = false;
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

%get intra comparison
intraSub = getTrials(imSub,conditions{1});

%get inter comparison
if isempty(conditions{2})
    matchTrials = findTrials(imSub,conditions{1});
    interSub = imSub(~matchTrials);
else
    interSub = getTrials(imSub,conditions{2});
end

%convert traces
if useFactors
    intraTraces = catBinnedFactors(intraSub,1);
    interTraces = catBinnedFactors(interSub,1);
else
    [~,intraTraces] = catBinnedTraces(intraSub);
    [~,interTraces] = catBinnedTraces(interSub);
end

%permute
intraTracePerm = permute(intraTraces,[3 1 2]);
interTracePerm = permute(interTraces,[3 1 2]);

%initialize
nPairsIntra = nchoosek(size(intraTracePerm,1),2);
nPairsInter = size(interTracePerm,1)*size(intraTracePerm,1);
nBins = size(intraTracePerm,3);
out.intraDistances = zeros(nBins,nPairsIntra);
out.interDistances = zeros(nBins,nPairsInter);

%get distance between every trial at every time point
for i = 1:nBins %for each timepoint
    
    out.intraDistances(i,:) = pdist(intraTracePerm(:,:,i));
    out.interDistances(i,:) = reshape(pdist2(intraTracePerm(:,:,i),...
        interTracePerm(:,:,i)),1,nPairsInter);
    
end

%take mean at each timepoint
out.intraDistancesMean = nanmean(out.intraDistances,2);
out.interDistancesMean = nanmean(out.interDistances,2);

%take std at each timepoint
out.intraDistanceSTD = nanstd(out.intraDistances,0,2);
out.interDistanceSTD = nanstd(out.interDistances,0,2);

%take sem
out.intraDistanceSEM = out.intraDistanceSTD/sqrt(size(out.intraDistances,2));
out.interDistanceSEM = out.interDistanceSTD/sqrt(size(out.interDistances,2));

%store yPosBins
yPosBins = imSub{1}.imaging.yPosBins;
out.yPosBins = yPosBins;
    
