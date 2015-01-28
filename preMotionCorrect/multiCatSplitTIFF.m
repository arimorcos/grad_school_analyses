function multiCatSplitTIFF(nPlanes,nExtraPlanes)
%catSplitTIFF.m Concatenates and splits tiff into component planes
%
%INPUTS
%nPlanes - number of actual planes
%nExtraPlanes - number of extra (flyback planes)
%
%ASM 10/13

%set default nPlanes and nExtraPlanes
DEFAULTNEXTRA = 1;
DEFAULTNPLANES = 4;
if nargin < 2; nExtraPlanes = DEFAULTNEXTRA; end;
if nargin < 1; nPlanes = DEFAULTNPLANES; end;

%set baseDir
baseDir = 'D:\DATA\2P Data\ResScan';

%set flag to false
gotFiles = false;

%initialize ind
ind = 1;

%get files
while ~gotFiles

    %get filenames
    [~,~,tiffFiles{ind}] = getTIFFNames(baseDir);
    
    %get catFileName
    cd(fileparts(tiffFiles{ind}{1}));
    [catFileName,catFilePath] = uiputfile('*.tif','Enter concatenated file name');
    catFileFullName{ind} = fullfile(catFilePath,catFileName);
    
    %ask if more files
    moreFilesets = questdlg('Are there more filesets?');
    switch moreFilesets
        case 'Yes'
            gotFiles = false;
            ind = ind + 1;
        case {'No','Cancel'}
            gotFiles = true;
    end
end

%run catSplitTIFF
for i = 1:length(tiffFiles) %for each fileset
    catSplitTIFF(nPlanes,nExtraPlanes,true,tiffFiles{i},catFileFullName{i});
end
    
    