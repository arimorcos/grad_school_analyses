function rateComp = compareSingletonErrorRates(errorMat,thresh)
%compareSingletonErrorRates.m Compares the error rate in single trial
%clusters to underlying error rate 
%
%INPUTS
%errorMat - nDSets x 1 cell array of error matrices. Each matrix contains
%   an array of nClusters x 2 in which column 1 is the number of errors and
%   column 2 is the total trials 
%
%OUTPUTS
%rateComp - table containing rate comparisons
%
%ASM 6/15

if nargin < 2 || isempty(thresh)
    thresh = 1;
end

%get nDatasets 
nDatasets = length(errorMat);

%initialize
underlyingErrorRate = nan(nDatasets,1);
fracSingleton = nan(nDatasets,1);

%loop through each dataset and calculate 
for dset = 1:nDatasets
    
    %find singleton clusters 
    singletonRows = errorMat{dset}(errorMat{dset}(:,2) <= thresh,:);
    
    %calculate fraction 
    singletonError = singletonRows(:,1)./singletonRows(:,2);
    fracSingleton(dset) = mean(singletonError);
    
    %calculate underlying error rate 
    totals = sum(errorMat{dset});
    underlyingErrorRate(dset) = totals(1)/totals(2);
    
end

%create a table 
rateComp = table(fracSingleton,underlyingErrorRate);