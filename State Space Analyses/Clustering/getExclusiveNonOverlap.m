function nonOverlap = getExclusiveNonOverlap(whichOverlap,whichNonOverlap)
%getExclusiveNonOverlap.m Gets the list of neurons which are only active in
%a single cluster
%
%INPUTS
%whichOverlap - nPoints x 1 cell array of nClusters x nClusters cell array
%   of overlapping neurons 
%whichNonOverlap - nPoints x 1 cell array of nClusters x nClusters cell array
%   of non-overlapping neurons 
%
%OUTPUTS
%nonOverlap - array of nonOverlapping neurons
%
%ASM 5/15

%get all of each 
tempOverlap = cellfun(@(x) cat(1,x{:}),whichOverlap,'UniformOutput',false);
allOverlap = unique(cat(1,tempOverlap{:}));
tempNonOverlap = cellfun(@(x) cat(1,x{:}),whichNonOverlap,'UniformOutput',false);
nonOverlap = unique(cat(1,tempNonOverlap{:}));

%remove neurons presnent in both 
nonOverlap(ismember(nonOverlap,allOverlap)) = [];