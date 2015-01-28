function [binarySeg, binarySegProj] = binarizeProjectICASeg(icaSeg)
%binarizeProjectICASeg.m Binarizes ica spatial filters and makes projection
%
%INPUTS
%icaSeg - m x n x nFilters array created by CellSortICA and rearranged by
%   fixDimensions
%
%OUTPUTS
%binarySeg - m x n x nFilters array with values of 0 or 1 indicating filter
%binarySegProj - m x n projection containing sum of all filters (regions of
%   overlap will have values greater than 1)
%
%ASM 10/13

%binarize
binarySeg = icaSeg;
binarySeg(binarySeg~=0) = 1;

%project
binarySegProj = sum(binarySeg,3);