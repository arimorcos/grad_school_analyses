function [tiffNames,tiffPaths,tiffFiles] = ...
    catSplitTIFF(nPlanes,nExtraPlanes,silent,tiffFiles,catFileFullName)
%catSplitTIFF.m Concatenates and splits tiff into component planes
%
%INPUTS
%nPlanes - number of actual planes
%nExtraPlanes - number of extra (flyback planes)
%silent - don't ask for files
%tiffFiles - cell array of filenames
%catFileFullName - name and path of catFile
%
%OUTPUTS
%tiffNames - 1 x nFiles cell array containing the names of the new tiffs
%tiffPaths - 1 x nFiles cell array containing the paths of the new tiffs
%tiffFiles - 1 x nFiles cell array containing the full path and name of the
%   new tiffs
%
%ASM 9/13

if nargin < 3
    silent = false;
    tiffFiles = {};
    catFileFullName = {};
end

%set default nPlanes and nExtraPlanes
DEFAULTNEXTRA = 1;
DEFAULTNPLANES = 4;
if nargin < 2; nExtraPlanes = DEFAULTNEXTRA; end;
if nargin < 1; nPlanes = DEFAULTNPLANES; end;

%concatenate
[catFileName, ~, catFilePath, tiff] = cat_tif(false,silent,...
    tiffFiles,catFileFullName);

%split up
[~,tiffBase] = regexp(catFileName,'.tif','match','split'); %remove .tif
tiffBase = tiffBase{1};
[tiffNames,tiffPaths,tiffFiles] = ...
    splitTIFFPlanes(tiff,tiffBase,nPlanes,nExtraPlanes,catFilePath);