function [similarPlanes, fracOverlap, segmentIDs] =...
    getPercentOverlap(icaSeg,overlapThresh)
%getPercentOverlap.m Finds percent overlap for each overlapping section of
%an image
%
%INPUTS
%icaSeg - m x n x nFilters array containing each filter (must be binary)
%overlapThresh - threshold for considering overlap to be same cell
%
%OUTPUTS
%similarPlanes - 1 x nSimilarPlanes cell array containing plane IDs of
%   planes with fracOverlap greater than overlapThresh
%fracOverlap - 1 x nOverlap cell array containing percentage overlap for
%   each involved segment
%segmentIDs - 1 x nOverlap cell array containing segment IDs for
%   percOverlap
%
%ASM 10/13

%create projection
icaProj = sum(icaSeg,3);

%only keep overlapping segments
overlaps = zeros(size(icaProj));
overlaps(icaProj > 1) = 1;

%segment overlaps
[labeledOverlap, nOverlap] = bwlabel(overlaps);

%initialize cell arrays
fracOverlap = cell(1,nOverlap);
segmentIDs = cell(1,nOverlap);
similarPlanes = {};

%for each overlap
for i = 1:nOverlap
    
    %get specific overlap
    [rowInd, colInd] = find(labeledOverlap == i);
    currOverlap = zeros(size(labeledOverlap));
    currOverlap(labeledOverlap == i) = 1;
    
    %convert to vector indices
    overlapInd = sub2ind(size(icaSeg),....
        repmat(rowInd',1,size(icaSeg,3)),...
        repmat(colInd',1,size(icaSeg,3)),...
        repmat(1:size(icaSeg,3),1,length(rowInd)));
    
    %find planes
    planeInd = icaSeg(overlapInd) ~= 0; %find all indices where region is nonzero
    planeInd = overlapInd(planeInd); %convert back to vector indices
    [~,~,planes] = ind2sub(size(icaSeg),planeInd); %convert to row,col,plane
    planes = unique(planes); %only keep unique values
    
    %store segment IDs
    segmentIDs{i} = planes;
    fracOverlap{i} = [];
    
    for j = 1:length(planes) %for each plane
        
        %determine overlap with overlapping region
        planeOverlap = currOverlap & icaSeg(:,:,planes(j));
        
        %get areas
        overlapArea = regionprops(planeOverlap,'AREA');
        planeArea = regionprops(icaSeg(:,:,planes(j)),'AREA');
        
        %get total area
        planeArea = sum([planeArea(:).Area]);
        overlapArea = sum([overlapArea(:).Area]);
        
        %percOverlap
        fracOverlap{i}(j) = overlapArea/planeArea;
        
    end
    
    %check if overlap is enough
    if sum(fracOverlap{i} >= overlapThresh) >= 2 %if at least two planes overlap 
        similarPlanes{length(similarPlanes)+1} = segmentIDs{i}(fracOverlap{i} >= overlapThresh);
    end
end

end


