function [varargout] = fixDimensions(varargin)
%fixDimensions.m Function to convert outputs of cellsort into height x
%width x plane
%
%ASM 10/13

for i=1:length(varargin)
    varargout{i} = permute(varargin{i},[2 3 1]);
end