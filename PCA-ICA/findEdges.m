function [row,col] = findEdges(image)
%findEdges.m Finds contours of binary array
%
%INPUTS 
%image - binary image 
%
%OUTPUTS
%row - column vector of row coordinates
%col - column vector of col coordinates
%
%ASM 10/13

% %create filter
% filter = [-1 -1 -1; -1 8 -1; -1 -1 -1];
% 
% %filter image
% edges = filter2(filter,image);
% 
% %get indices
% [row,col] = find(edges>0);

%find element to start search
[rowInd, colInd] = find(image > 0,1,'first');

%perform search
B = bwtraceboundary(image,[rowInd,colInd],'NE');

%get row and col
row = B(:,2);
col = B(:,1);