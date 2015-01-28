function [planeIterations, planeItRanges] = alignSplitSync(syncFile,nPlanes,...
    nExtraPlanes)
%alignSplitSync.m Aligns sync to virmen and then splits based on frames
%
%INPUTS 
%syncFile - sync file path and filename. If empty, asks for
%        sync file. 
%nPlanes - nPlanes imaged from 
%nExtraPlanes - nExtraPlanes (flyback)
%
%OUTPUTS 
%planeIterations - 1 x nPlanes cell containing 1 x nFrames cells of the 
%                  iteration numbers corresponding to each plane
%planeItRange - 1 x nPlanes cell containing iteration ranges for each frame 
%               of each plane
%
%ASM 12/14 based on alignSplitPClamp

if nargin < 3 || isempty(nExtraPlanes)
    nExtraPlanes = 1;
end
if nargin < 2 || isempty(nPlanes)
    nPlanes = 4;
end
if nargin < 1 || isempty(syncFile)
    %get file
    [syncFileName,syncPathName] = uigetfile('*.mat');
    syncFile = fullfile(syncPathName,syncFileName);
end


%align
[frameItRanges,frameIterations] = alignVirmenSync(syncFile,2);

%split
[planeItRanges, planeIterations] = splitPClamp(frameItRanges,frameIterations,...
    nPlanes,nExtraPlanes);