function procFilt = removeOverlappingRegions(filters)
%removeOverlappingRegions.m Removes regions of filters containing more than
%one filter
%
%INPUTS
%filters - m x n x nFilters binary array
%
%OUTPUTS
%procFilters - m x n x nFilters binary array containing no overlaps
%
%ASM 5/14

%take sum
filtSum = sum(filters,3);

%find indices greater than 1 
filtDelete = filtSum > 1;

%repmat filtDelete
filtDelete = repmat(filtDelete,1,1,size(filters,3));

%set all values to 0 
procFilt = filters;
procFilt(filtDelete) = 0;