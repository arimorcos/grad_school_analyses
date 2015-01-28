function folders = getMultipleFolders(baseDir)
%getMultipleFolders.m Uses uigetdir to get multiple folders
%
%INPUTS
%baseDir - base directory for folder dialog. If empty, current directory
%
%OUTPUTS
%folders - cell array of folders
%
%ASM 11/13

if nargin < 1 || isempty(baseDir)
    baseDir = [];
end

%initialize
gotFolders = false;
folders = {};

%create while loop
while ~gotFolders
    tempFolder = uigetdir(baseDir); %get directory
    if tempFolder ~= 0 %check if no directory selected
        folders = [folders tempFolder]; %#ok<AGROW>
    end
    moreFiles = questdlg('Are there more folders?','More Folders?',...
        'Yes','No','No');
    if strcmp(moreFiles,'No') %if no more files
        gotFolders = true;
    end        
end