function [start,stop] = findContinuousRegions(data,thresh)
%findContinuousRegions.m Finds continuous, regions above a threshold within
%a vector
%
%INPUTS
%data - data vector
%thresh - threshold. Default is 0
%
%OUTPUTS
%start - 1 x nContRegions array of start indices
%stop - 1 x nContRegions array of stop indices
%
%ASM 9/14

%set thresh if not provided
if nargin < 2 || isempty(thresh)
    thresh = 0;
end

%set values below thresh to 0 
data(data <= thresh) = 0;

%take diff of data
diffData = diff(data);

%find all indices with a positive diff
posIndAll = find(diffData>0);

%remove posInds where previous ind is also positive
prevIndIsZero = data(posIndAll) == 0;
start = posIndAll(prevIndIsZero)+1;

%add first index if starts above thresh
if data(1) > thresh
    start = [1, start];
end

%find all indices with a negative diff
negIndAll = find(diffData<0);

%remove negInds where next ind is not zero
nextIndIsZero = data(negIndAll+1) == 0;
stop = negIndAll(nextIndIsZero);

%add last index if ends above thresh
if data(end) > thresh
    stop = [stop, length(data)];
end