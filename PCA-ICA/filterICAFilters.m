function [filteredSeg,keptSeg] = filterICAFilters(icaSeg,micronsPerPix,...
    minArea,maxArea,overlapThresh)
%filterICAFilters.m Filters out ica filters based on several paramters to
%ensure only cells are retained
%
%INPUTS
%icaSeg - m x n x nFilters array containing each filter (must be binary)
%micronsPerPix - number of microns per pixel side (assumes square pixels)
%minArea - minimum cell area in microns^2
%maxArea - maximum cell area in microns^2
%overlapThresh - threshold for considering overlap to be same cell (between
%   0 and 1)
%
%OUTPUTS
%filteredSeg - m x n x nRealFilters array containing each filter which
%   meets cell criteria
%keptSeg - 1 x nFilters boolean of whether or not segments retained
%
%ASM 10/13

%get nFilters 
nFilters = size(icaSeg,3);

%conver min/maxArea to pixels
minArea = minArea/(micronsPerPix^2);
maxArea = maxArea/(micronsPerPix^2);

%initialize
shouldKeep = true(1,nFilters);

%get percentage overlap
[similarPlanes, ~, ~] = getPercentOverlap(icaSeg,overlapThresh);

%combine similar planes
shouldRemove = false(1,size(icaSeg,3));
for i = 1:length(similarPlanes) %for each set of similar planes
    
    %sum plane
    summedPlane = sum(icaSeg(:,:,similarPlanes{i}),3);
    summedPlane(summedPlane~=0) = 1; %binarize
    
    %replace first plane with summed plane
    icaSeg(:,:,similarPlanes{i}(1)) = summedPlane;
    
    %store indices of planes to remove
    shouldRemove(similarPlanes{i}(2:end)) = true;
end

%inscribe circle in each filter
for i = 1:nFilters %for each filter
    
    %get edges
    [edgeRows,edgeCols] = findEdges(icaSeg(:,:,i));
    
    %get maximum inscribed cicle radius
    [~,~,circRad] = findInscribedCircle(edgeRows,edgeCols);
    
    %calculate area
    circArea = pi*circRad^2;
    
    %filter based on area
    if circArea < minArea || circArea > maxArea
        shouldKeep(i) = false;
    end
    
end

%create keptSeg
keptSeg = shouldKeep & ~shouldRemove;

%create filteredSeg
filteredSeg = icaSeg(:,:,keptSeg);


