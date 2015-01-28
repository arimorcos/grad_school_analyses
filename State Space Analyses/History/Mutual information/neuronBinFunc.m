function edges = neuronBinFunc(x, nb)
%neuronBinFunc.m binning function for mutual information calculation which
%bins everything below a set threshold to 0 and then everything above that
%in a linearly spaces fashion
%
%INPUTS
%x - a column array contatining the values which need to
%                     be quantized.
%nb - number of bins. The first bin will be used for low values. Anything
%   else will be linearly spaced to create extra bins
%
%OUTPUTS
%edges - an (NB+1)-long array of strictly monotonically
%                     increasing values corresponding to the edges of the 
%                     quantization bins
%
%ASM 12/14

%set std thresh
nSTD = 2;

%initialize
edges = nan(nb+1,1);
edges(1) = min(x);

%%%%%%%%%%%%%%%%find lower threshold %%%%%%%%%%%%%%%%%%%%%%%
%get distribution of values
[dFFHist,distVals] = hist(x,200);

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
minThresh = distVals(thresholdInd);

%%%%%%%%%%%%%%%%%%%% get other thresholds %%%%%%%%%%%%%%%%%%%%%%%%%%
%get max of x
maxVal = max(x);

%get other bins
edges(2:end) = linspace(minThresh,maxVal,nb);
