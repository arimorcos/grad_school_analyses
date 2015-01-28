function [threshTraces,completeTraceThresh] = thresholdTraces(completeDFFTrace,...
    imSub,nSTD,minFrames)
%thresholdTraces.m Thresholds fluorescence traces by setting all values
%below nSTD above the peak of the distribution to 0
%
%INPUTS
%completeDFFTrace - nNeurons x nFrames trace
%imSub - subsetted imaging data (must contain imaging data only)
%nSTD - number of standard deviations above peak to threshold by
%minFrames - minFrames active
%
%OUTPUTS
%threshTraces - nNeurons x nBins x nTrials array of binned traces
%
%ASM 1/14

if nargin < 4 || isempty(minFrames)
    minFrames = 6;
end
if nargin < 3 || isempty(nSTD)
    nSTD = 3;
end

%get nNeurons
nNeurons = size(completeDFFTrace,1);

%extract traces
threshTraces = catBinnedTraces(imSub);

%nTrials
nTrials = length(imSub);

%initialize thresholds
thresholds = zeros(1,nNeurons);

completeTraceThresh = completeDFFTrace;

%cycle through each neuron and determine the threshold
for i = 1:nNeurons %for each neuron
    
    %get relevant trace
    dFFTrace = completeDFFTrace(i,:);
    
    %get distribution of values
    [dFFHist,distVals] = hist(dFFTrace,50);
    
    %find peak 
    [maxCount,maxInd] = max(dFFHist);
    
    %get proportion of max 
    sigmaFac = exp(-(nSTD^2)/2);
    
    %get lower hist count
    lowerHistCount = sigmaFac*maxCount;
    
    %find last value below lowerHistCount 
    lowerInd = find(dFFHist(1:maxInd) <= lowerHistCount,1,'last');
    if isempty(lowerInd) %set to 0 if none found
        lowerInd = 0;
    end
    
    %get distance to peak 
    peakDistance = maxInd - lowerInd;
    
    %reflect distance across peak
    thresholdInd = maxInd + peakDistance;
    
    %get dF/F value of threshold Ind 
    thresholds(i) = distVals(thresholdInd);
    
    %floor values below threshold to 0 
    threshSub = threshTraces(i,:,:);
    threshSub(threshSub < thresholds(i)) = 0;
    threshTraces(i,:,:) = threshSub;
    
    %remove non-contiguous transient
    for j = 1:nTrials
        %get contiguous regions
        regions = bwlabel(threshTraces(i,:,j));
        
        %get area
        regProps = regionprops(regions,'Area');
        regAreas = cat(2,regProps.Area);
        
        %find values below thresh
        floorInds = find(regAreas < minFrames);
        
        %floor values of one
        threshTraces(i,ismember(regions,floorInds),j) = 0;
        
    end
    
    %get complete trace
    completeTraceThresh(i,dFFTrace < thresholds(i)) = 0;
    
end

    
    
    

