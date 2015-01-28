function catSplitRedGreenTIFF(nPlanes,nExtraPlanes)
%catSplitTIFF.m Concatenates and splits tiff into component planes
%
%INPUTS
%nPlanes - number of actual planes
%nExtraPlanes - number of extra (flyback planes)
%
%ASM 9/13

%set default nPlanes and nExtraPlanes
DEFAULTNEXTRA = 1;
DEFAULTNPLANES = 4;
if nargin < 2; nExtraPlanes = DEFAULTNEXTRA; end;
if nargin < 1; nPlanes = DEFAULTNPLANES; end;

%concatenate
[catFileName, ~, catFilePath, tiff] = cat_tif(false);

%split up
[~,tiffBase] = regexp(catFileName,'.tif','match','split'); %remove .tif
tiffBase = tiffBase{1};
splitTIFFPlanes(tiff,tiffBase,nPlanes,nExtraPlanes,catFilePath,{'green','red'});