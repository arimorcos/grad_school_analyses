function [planeItRange, planeIterations] = splitPClamp(frameItRange,frameIterations,...
    nPlanes,nExtraPlanes)
%splitPClamp.m Splits up output of alignVirmenPClamp according to frames
%
%INPUTS
%frameItRange - nFrames x 2 array of start and stop iterations for each frame
%frameIterations - 1 x nFrames cell of iterations corresponding to each
%   frame
%nPlanes - nPlanes imaged from
%nExtraPlanes - nExtraPlanes (flyback)
%
%OUTPUTS
%planeIterations - 1 x nPlanes cell containing 1 x nChannels cell
%   containing 1 x nFrames cells of the iteration numbers corresponding to 
%   each plane
%planeItRange - 1 x nPlanes cell containing 1 x nChannels cell containing
%   iteration ranges for each frame of each plane
%
%ASM 10/13


if nargin < 4 || isempty(nExtraPlanes)
    nExtraPlanes = 1;
end
if nargin < 3 || isempty(nPlanes)
    nPlanes = 4;
end

%get nFrames
nFrames = size(frameItRange,1);

%initialize
planeItRange = cell(1,nPlanes);
planeIterations = cell(1,nPlanes);

%cycle through each plane 
for planeInd = 1:nPlanes
        
    %generate planeFrame indices
    planeFrameInd = planeInd:nPlanes+nExtraPlanes:nFrames;
    
    %get subsets
    planeItRange{planeInd} = frameItRange(planeFrameInd,:);
    planeIterations{planeInd} = frameIterations(planeFrameInd);

end
