function noise = calculateNoise(trace,nSTD)
%calculateNoise.m Calculates noise by taking a distribution of local
%values within a trace and taking the left half of the peak to be a normal
%distribution (calculate STD based on that half), then reflecting the STD
%about the max and counting that as the noise level.

%get distribution of values
[dFFHist,distVals] = hist(trace,50);

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
thresholdInd = min(thresholdInd,length(distVals));

%get dF/F value of threshold Ind
noise = distVals(thresholdInd);
end