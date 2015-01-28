function completeTraceThresh = thresholdCompleteTrace(completeDFFTrace,nSTD,minFrames)
%thresholdTraces.m Thresholds fluorescence traces by setting all values
%below nSTD above the peak of the distribution to 0
%
%INPUTS
%completeDFFTrace - nNeurons x nFrames trace
%nSTD - number of standard deviations above peak to threshold by
%
%OUTPUTS
%completeTraceThresh - nNeurons x Frames array of thresholded traces
%
%ASM 1/14

%get nNeurons
nNeurons = size(completeDFFTrace,1);

%initialize thresholds
thresholds = zeros(1,nNeurons);

completeTraceThresh = completeDFFTrace;

%cycle through each neuron and determine the threshold
for i = 1:nNeurons %for each neuron
    
    %get relevant trace
    dFFTrace = completeDFFTrace(i,:);
    
    %set values below -100 to -100
    dFFTrace(dFFTrace < -100) = -100;
    
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
    
    %get complete trace
    completeTraceThresh(i,dFFTrace < thresholds(i)) = 0;
    
    %%%%%%remove non-contiguous transient
    
    %get contiguous regions
    regions = bwlabel(completeTraceThresh(i,:));
    
    %get area
    regProps = regionprops(regions,'Area');
    regAreas = cat(2,regProps.Area);
    
    %find values below thresh
    floorInds = find(regAreas < minFrames);
    
    %floor values of one
    completeTraceThresh(i,ismember(regions,floorInds)) = 0;
    
end

    
    
    

