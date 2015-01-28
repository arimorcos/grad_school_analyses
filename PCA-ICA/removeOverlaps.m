function [nonOver, nonOverProj] = removeOverlaps(icaSeg,icaProj)
%removeOverlaps.m Removes overlapping segments from ica spatial filters
%
%INPUTS
%
%icaSeg - m x n x nFilters array containing each filter (must be binary)
%icaProj - m x n projection of icaSeg (regions > 1 suggest overlapping)
%
%OUTPUTS
%
%nonOver - m x n x nFilters array with each filter w/o overlapping segments
%nonOverProj - m x n projection of nonOver
%
%ASM 10/13

%find overlap regions
[rowInd, colInd] = find(icaProj > 1);

%convert to indices
overlapInd = sub2ind(size(icaSeg),....
    repmat(rowInd',1,size(icaSeg,3)),...
    repmat(colInd',1,size(icaSeg,3)),...
    repmat(1:size(icaSeg,3),1,length(rowInd)));

%make non overlap
nonOver = icaSeg;
nonOver(overlapInd) = 0;

%make projection
nonOverProj = sum(nonOver,3);