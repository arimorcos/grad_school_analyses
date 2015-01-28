function [tiffNames,tiffPaths,tiffFiles] = autoMultiCatSplitTIFF(nPlanes,nExtraPlanes)
%autoMultiCatSplitTIFF.m Concatenates and splits all tiffs  in folder  into
%component planes
%
%INPUTS nPlanes - number of actual planes nExtraPlanes - number of extra
%(flyback planes)
%
%OUTPUTS
%tiffNames - 1 x nFiles cell array containing the names of the new tiffs
%tiffPaths - 1 x nFiles cell array containing the paths of the new tiffs
%tiffFiles - 1 x nFiles cell array containing the full path and name of the
%   new tiffs
%
%ASM 10/13

%set default nPlanes and nExtraPlanes
DEFAULTNEXTRA = 1;
DEFAULTNPLANES = 4;
if nargin < 2; nExtraPlanes = DEFAULTNEXTRA; end;
if nargin < 1; nPlanes = DEFAULTNPLANES; end;

%set baseDir
baseDir = 'D:\DATA\2P Data\ResScan';

%get folder
folder = uigetdir(baseDir);

%change to folder
origDir = cd(folder);

%get list of files in folder
fileList = dir('*.tif');
fileList = {fileList(:).name};

%add folder to each file
fullFileList = cellfun(@(x) fullfile(folder,x),fileList,'UniformOutput',false);

%get number of stacks
stackNums = regexp(fileList,'(?<=\w*_)\d\d\d(?=_)','match'); 
stackNums = stackNums(cell2mat(cellfun(@(x) ~isempty(x),stackNums,'UniformOutput',false))); %remove empty cells
stackNums = cellfun(@(x) x{1},stackNums,'UniformOutput',false); %open each cell
[uniqueStacks,~,fileIDs] = unique(stackNums);
nStacks = length(uniqueStacks);

%get catFullFileNames
catFiles = regexp(fileList,'\w*_\d\d\d(?=_)','match');
catFiles = catFiles(cell2mat(cellfun(@(x) ~isempty(x),catFiles,'UniformOutput',false))); %remove empty cells
catFiles = cellfun(@(x) x{1},catFiles,'UniformOutput',false);
catFiles = unique(catFiles);
catFileFullName = cellfun(@(x) [fullfile(folder,x),'.tif'],catFiles,'UniformOutput',false);

%change back to origDir
cd(origDir);

%initialize names
tiffNames = {};
tiffPaths = {};
tiffFiles = {};

%run catSplitTIFF
for i = 1:nStacks %for each fileset
    [tempNames,tempPaths,tempFiles] = catSplitTIFF(nPlanes,nExtraPlanes,...
        true,fullFileList(fileIDs == i),catFileFullName{i});
    
    %concatenate
    tiffNames = [tiffNames,tempNames];
    tiffPaths = [tiffPaths,tempPaths];
    tiffFiles = [tiffFiles,tempFiles];
end
    
    