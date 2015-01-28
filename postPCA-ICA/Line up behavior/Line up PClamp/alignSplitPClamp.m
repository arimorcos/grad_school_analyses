function [planeIterations, planeItRanges] = alignSplitPClamp(pFile,nPlanes,...
    nExtraPlanes)
%alignSplitPClamp.m Aligns pClamp to virmen and then splits based on frames
%
%INPUTS 
%pFile - patch clamp file path and filename. If empty, asks for
%        pFile. 
%nPlanes - nPlanes imaged from 
%nExtraPlanes - nExtraPlanes (flyback)
%
%OUTPUTS 
%planeIterations - 1 x nPlanes cell containing 1 x nFrames cells of the 
%                  iteration numbers corresponding to each plane
%planeItRange - 1 x nPlanes cell containing iteration ranges for each frame 
%               of each plane
%
%ASM 10/13

if nargin < 3 || isempty(nExtraPlanes)
    nExtraPlanes = 1;
end
if nargin < 2 || isempty(nPlanes)
    nPlanes = 4;
end
if nargin < 1 || isempty(pFile)
    %get file
    [pFileName,pPathName] = uigetfile('*.abf');
    pFile = fullfile(pPathName,pFileName);
end


%align
[frameItRanges,frameIterations] = alignVirmenPClamp(pFile,1);

%split
[planeItRanges, planeIterations] = splitPClamp(frameItRanges,frameIterations,...
    nPlanes,nExtraPlanes);